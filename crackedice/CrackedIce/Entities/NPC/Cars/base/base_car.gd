class_name BaseCar
extends VehicleBody3D

signal car_collided(force: float)

@export var steer_speed = 0.1
@export var steer_limit = 1.0
@export var engine_force_value = 100
@export var throttle_speed := 10.0
@export var brake_speed := 10.0
@export var motor_drag := 0.005
@export var max_rpm := 7000.0
@export var torque_curve : Curve
@export var max_torque := 300.0
@export var motor_moment := 0.5
@export var idle_rpm := 1000.0
@export var clutch_out_rpm := 3000.0
@export_group("Gearbox")
## Transmission gear ratios, the size of the array determines the number of gears
@export var gear_ratios : Array[float] = [ 3.8, 2.3, 1.7, 1.3, 1.0, 0.8 ]

## Final drive ratio
@export var final_drive := 3.2
@export var reverse_ratio := 3.3
## Time it takes to change gears on up shifts in seconds
@export var shift_time := 0.2

## Heat stuff
@export var resilience: float = 4.0

## Damage stuff
@export var block_damage: int = 10
@export var heat_resistance: int = 10

const ANGULAR_VELOCITY_TO_RPM := 60.0 / TAU

var steer_target = 0

var throttle_input := 0.0
var brake_input := 0.0
var damage: float = 0 : set = _set_damage
var target_heat: float = 0.0
var engine_heat: float = 0.0
var heat: float = 0 : set = _set_heat
var hit_heat: float = 0.0

var ambient_temp: float = -0.03 : set = _set_ambient_temp

var local_velocity := Vector3.ZERO
var previous_global_position := Vector3.ZERO
var throttle_amount := 0.0
var full_throttle_amount := 1.0
var motor_rpm := 0.0
var torque_output := 0.0
var motor_is_redline := false
var clutch_amount := 0.0
var need_clutch := false
var clutch_input := 0.0
var is_shifting := false
var current_gear := 0 : set = _set_current_gear
var brake_amount := 0.0
var requested_gear := 0
var speed := 0.0
var average_drive_wheel_radius := 0.0
var last_shift_delta_time := 0.0
var delta_time := 0.0
var is_up_shifting := false
var complete_shift_delta_time := 0.0
var throttle_factor := 1.0
var prev_velocity: Vector3
var engine_force_bonus := 1.0
var freeze_penalty := 1.0
var main_body_material: Material

func _ready():
	connect_signals()
	initialize()

func connect_signals():
	EventBus.max_rpm_requested.connect(_send_max_rpm_value)
	EventBus.damage_made.connect(_set_damage)
	EventBus.heat_applied.connect(_set_heat)
	EventBus.ambient_temperature_changed.connect(_set_ambient_temp)

func initialize():
	previous_global_position = global_transform.origin
	average_drive_wheel_radius = $WheelFrontRight.wheel_radius
	EventBus.ambient_temperature_requested.emit()
	main_body_material = %main_body.get_active_material(0)

func _set_damage(value):
	damage += value
	print("Total damage: ", damage)
	engine_force_bonus = 1 - (damage / 400)
	if damage >= 100:
		engine_force_bonus = 0
		final_drive = 0
		idle_rpm = 0
		motor_rpm = 0
		brake = brake_speed * 4
		torque_output = 0
		heat_resistance = 0
		EventBus.car_destroyed.emit()


func _set_ambient_temp(value):
	ambient_temp = value

func _set_heat(value):
	heat = clamp(value, -100, 100)
	# if heat is grater than 50 apply damage
	if heat > 50.0:
		EventBus.car_hit_damage.emit(heat / 6000)
	elif heat < -25.0:
		# low freeze penalty
		freeze_penalty = 1.0 + (heat / 100.0)
	else:
		freeze_penalty = 1.0
	EventBus.heat_changed.emit(heat)

func _send_max_rpm_value():
	EventBus.max_rpm_changed.emit(max_rpm)

func _set_current_gear(value):
	current_gear = value
	var gear_string = ""
	# match the gears with R, 1, 2, 3, 4, 5
	match current_gear:
		-1:
			gear_string = "R"
		0:
			gear_string = "1"
		1:
			gear_string = "2"
		2:
			gear_string = "3"
		3:
			gear_string = "4"
		4:
			gear_string = "5"
		5:
			gear_string = "6"

	EventBus.gear_changed.emit(gear_string)

func _physics_process(delta):
	prev_velocity = linear_velocity
	speed = linear_velocity.length()*Engine.get_frames_per_second()*3.6*delta
	EventBus.speed_changed.emit(round(speed * 1.8))
	traction(speed)

	delta_time += delta
	local_velocity = lerp(((global_transform.origin - previous_global_position) / delta) * global_transform.basis, local_velocity, 0.5)
	previous_global_position = global_position

	process_throttle(delta)
	process_motor(delta)
	process_transmission(delta)
	process_target_heat(delta)
	process_heat(delta)

	# var fwd_mps = transform.basis.x.x
	steer_target = Input.get_action_strength("Steer Left") - Input.get_action_strength("Steer Right")
	steer_target *= steer_limit * 50 / (50 + speed)

	throttle_input = max(pow(Input.get_action_strength("Throttle"), 2.0), pow(Input.get_action_strength("Full Throttle"), 2.0))

	if Input.is_action_pressed("Full Throttle"):
		# Increase engine force at cost of wheel slip
		if speed < 10 and speed != 0:
			engine_force = -clamp((engine_force_value * engine_force_bonus * freeze_penalty) * 2, 0, 3000)
		else:
			engine_force = -clamp((engine_force_value * engine_force_bonus * freeze_penalty) * 1.2 * get_gear_ratio(current_gear), 0, 7500)
		full_throttle_amount = 0.1
		throttle_factor = 2.0
		# Slip penalty
		$WheelFrontLeft.wheel_friction_slip=1.25
		$WheelFrontRight.wheel_friction_slip=1.25
		$WheelRearRight.wheel_friction_slip=1
		$WheelRearLeft.wheel_friction_slip=1

		# Roll influence penalty
		$WheelFrontLeft.wheel_roll_influence= 0.5
		$WheelFrontRight.wheel_roll_influence= 0.5
		$WheelRearRight.wheel_roll_influence= 0.7
		$WheelRearLeft.wheel_roll_influence = 0.7

	else:

		full_throttle_amount = 1.0
		throttle_factor = 1.0
		engine_force = 0

	if Input.is_action_pressed("Throttle"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		if speed < 10 and speed != 0:
			engine_force = -clamp((engine_force_value * engine_force_bonus * freeze_penalty) * 1.5, 0, 3000)
		else:
			engine_force = -clamp((engine_force_value * engine_force_bonus * freeze_penalty) * get_gear_ratio(current_gear), 0, 7500)
		$WheelFrontLeft.wheel_friction_slip  = 2.0
		$WheelFrontRight.wheel_friction_slip = 2.0
		$WheelRearRight.wheel_friction_slip  = 2.25
		$WheelRearLeft.wheel_friction_slip   = 2.25

		$WheelFrontLeft.wheel_roll_influence  = 0.4
		$WheelFrontRight.wheel_roll_influence = 0.4
		$WheelRearRight.wheel_roll_influence  = 0.3
		$WheelRearLeft.wheel_roll_influence	  = 0.3

	brake_input = Input.get_action_strength("Brakes")

	if Input.get_action_strength("Brakes"):
	# Increase engine force at low speeds to make the initial acceleration faster.
		# print("forwad velocity: ", str(global_transform.basis.z.dot(body.velocity)))
		if local_velocity.z < -0.2:
			brake = brake_speed
			engine_force *= 0.2
		else:
			engine_force = -(engine_force_bonus * engine_force_value * freeze_penalty) * get_gear_ratio(-1)
			$WheelFrontLeft.wheel_friction_slip=1.8
			$WheelFrontRight.wheel_friction_slip=1.8
			$WheelRearRight.wheel_friction_slip=1.6
			$WheelRearLeft.wheel_friction_slip=1.6
	else:
		brake = 0

	if Input.is_action_pressed("Handbrake"):
		# brake front wheels
		$WheelFrontLeft.brake = brake_speed * 4
		$WheelFrontRight.brake = brake_speed * 4

		# brake rear wheels
		$WheelRearRight.brake = brake_speed
		$WheelRearLeft.brake = brake_speed

		engine_force *= 0.8

		$WheelFrontLeft.wheel_friction_slip=0.9
		$WheelFrontRight.wheel_friction_slip=0.9
		$WheelRearRight.wheel_friction_slip=0.5
		$WheelRearLeft.wheel_friction_slip=0.5

	steering = move_toward(steering, steer_target, steer_speed * 25 / (25 + speed))


func traction(speed):
	apply_central_force(Vector3.DOWN*speed*2)

func process_throttle(delta : float):
	var throttle_delta := throttle_speed * delta * throttle_factor
	if (throttle_input < throttle_amount):
		throttle_amount -= throttle_delta
		if (throttle_input > throttle_amount):
			throttle_amount = throttle_input

	elif (throttle_input >= throttle_amount):
		throttle_amount += throttle_delta
		if (throttle_input < throttle_amount):
			throttle_amount = throttle_input

	## Cut throttle at redline and when shifting
	if motor_is_redline or is_shifting:
		throttle_amount = 0.0

	## Disengage clutch when shifting or below motor idle
	if need_clutch or is_shifting:
		clutch_amount = 1.0
	else:
		clutch_amount = clutch_input

func process_motor(delta : float):
	var drag_torque := motor_rpm * motor_drag
	torque_output = get_torque_at_rpm(motor_rpm) * throttle_amount
	## Adjust torque based on throttle input, clutch input, and motor drag
	torque_output -= drag_torque * (1.0 + (clutch_amount * (1.0 - throttle_amount)))

	## Prevent motor from outputing torque below idle or far beyond redline
	var new_rpm := motor_rpm
	new_rpm += ANGULAR_VELOCITY_TO_RPM * delta * torque_output / motor_moment
	motor_is_redline = false
	if new_rpm > (max_rpm) or new_rpm <= idle_rpm:
		torque_output = 0.0
		if new_rpm > max_rpm:
			motor_is_redline = true

	motor_rpm += ANGULAR_VELOCITY_TO_RPM * delta * (torque_output - drag_torque) / motor_moment

	## Disengage clutch when near idle
	if motor_rpm < idle_rpm + 100:
		need_clutch = true
	elif new_rpm > clutch_out_rpm:
		need_clutch = false

	motor_rpm = maxf(motor_rpm, idle_rpm)
	# add heat based on rpm plus time throtled
	engine_heat = clampf(sqrt(motor_rpm - idle_rpm) * 6.5 / max_rpm, 0.0, 1.0)
	EventBus.rpm_changed.emit(motor_rpm)

func process_transmission(delta : float):
	if is_shifting:
		if delta_time > complete_shift_delta_time:
			complete_shift()
		return

	## For automatic transmissions to determine when to shift the current wheel speed and
	## what the wheel speed would be without slip are used. This allows vehicles to spin the
	## tires without immidiately shifting to the next gear.

	var reversing := false
#	print(d " + str(speed))
	var ideal_wheel_spin := speed / average_drive_wheel_radius

	var current_ideal_gear_rpm := gear_ratios[current_gear - 1] * final_drive * ideal_wheel_spin * ANGULAR_VELOCITY_TO_RPM

	if current_gear == -1:
		reversing = true

	if not reversing:
		var next_gear_rpm := 0.0
		if current_gear < gear_ratios.size():
			next_gear_rpm = get_gear_ratio(current_gear + 1) * ideal_wheel_spin * ANGULAR_VELOCITY_TO_RPM
		var previous_gear_rpm := 0.0
		if current_gear - 1 > 0:
			previous_gear_rpm = get_gear_ratio(current_gear - 1) *  ideal_wheel_spin * ANGULAR_VELOCITY_TO_RPM

		if current_gear < gear_ratios.size():
			if current_gear > 0:
				# calculate the shift rpm based on current gear: more gear means higher rpm to shift
				if (current_ideal_gear_rpm + motor_rpm) * 0.5 > (max_rpm * 0.7 * (1 - (full_throttle_amount / (1 + sqrt(current_gear))))):
					if delta_time - last_shift_delta_time > shift_time:
						shift(1)
			elif current_gear <= 0 and motor_rpm > clutch_out_rpm:
				shift(1)
		if current_gear - 1 > 0:
			if current_gear > 1 and previous_gear_rpm < 0.3 * max_rpm * (1 - (full_throttle_amount / (1 + sqrt ((current_gear - 1))))):
				if delta_time - last_shift_delta_time > shift_time:
					shift(-1)

	if absf(current_gear) <= 1:
		if not reversing:
			if speed < 1.0 or local_velocity.z > 0:
				if delta_time - last_shift_delta_time > shift_time:
					shift(-1)
		else:
			if speed < 1.0 or local_velocity.z < 0:
				if delta_time - last_shift_delta_time > shift_time:
					shift(1)

func process_target_heat(delta : float):
	target_heat += ambient_temp + engine_heat
	target_heat = clamp(target_heat, -100.0, 200.0)

	if target_heat <= 10:
		main_body_material.set_shader_parameter("snow_threshold", (target_heat + 100) / 100.0)
		main_body_material.set_shader_parameter("snow_blend_range", (-target_heat + 10) / 110.0)
		main_body_material.set_shader_parameter("metallic", ((target_heat + 100) / 100.0) + 0.5)
	else:
		main_body_material.set_shader_parameter("snow_threshold", 1.05)
		main_body_material.set_shader_parameter("snow_blend_range", 0.005)
		main_body_material.set_shader_parameter("metallic", 1.5)

func process_heat(delta : float):
	# smooth lerp between current heat and target heat
	# if target heat is greater than current heat do not apply heat resistance
	heat += hit_heat
	target_heat += hit_heat / heat_resistance
	hit_heat = 0
	if target_heat > heat:
		heat = lerp(heat, target_heat, delta)
	else:
		# if target heat is less than current heat apply heat resistance
		heat = lerp(heat, target_heat, delta / (1 + heat_resistance))
	

func get_torque_at_rpm(lookup_rpm : float) -> float:
	var rpm_factor = clamp(lookup_rpm / max_rpm, 0.0, 1.0)
	var torque_factor = torque_curve.sample_baked(rpm_factor)
	return torque_factor * max_torque

func shift(count : int):
	if is_shifting:
		return

	## handles gear change requests and timings
	requested_gear = current_gear + count

	if requested_gear <= gear_ratios.size() and requested_gear >= -1:
		if current_gear == 0:
			complete_shift()
		else:
			complete_shift_delta_time = delta_time + shift_time
			clutch_amount = 1.0
			is_shifting = true
			if count > 0:
				is_up_shifting = true

func complete_shift():
	## Called when it is time to complete a shift in progress
	if current_gear == -1:
		brake_amount = 0.0
	if requested_gear < current_gear:
		var wheel_spin := speed / average_drive_wheel_radius
		var requested_gear_rpm := gear_ratios[requested_gear - 1] * final_drive * wheel_spin * ANGULAR_VELOCITY_TO_RPM
		motor_rpm = lerpf(motor_rpm, requested_gear_rpm, 0.6)
	current_gear = requested_gear
	last_shift_delta_time = delta_time
	is_shifting = false
	is_up_shifting = false

func get_gear_ratio(gear : int) -> float:
	if gear > 0:
		return gear_ratios[gear - 1] * final_drive
	elif gear == -1:
		return -reverse_ratio * final_drive
	else:
		return 0.0

func _on_body_entered(body:Node):
	var impulse = mass * (linear_velocity - prev_velocity)
	impulse = sqrt(impulse.length()) / resilience
	# if the damage is greater than 10, do the damage
	hit_heat = clamp(impulse, 0.0, 100.0)
	if impulse > block_damage:
		EventBus.car_hit_damage.emit(impulse)
