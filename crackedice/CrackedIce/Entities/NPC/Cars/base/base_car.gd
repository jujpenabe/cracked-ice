class_name BaseCar
extends VehicleBody3D

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
@export var engine_force_value = 100
@export var throttle_speed := 20.0
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

const ANGULAR_VELOCITY_TO_RPM := 60.0 / TAU

var steer_target = 0

var throttle_input := 0.0
var brake_input := 0.0

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
var current_gear := 0
var brake_amount := 0.0
var requested_gear := 0
var speed := 0.0
var average_drive_wheel_radius := 0.0
var last_shift_delta_time := 0.0
var delta_time := 0.0
var is_up_shifting := false
var complete_shift_delta_time := 0.0

func _ready():
	initialize()

func initialize():
	previous_global_position = global_transform.origin
	average_drive_wheel_radius = $WheelFrontRight.wheel_radius


func _physics_process(delta):
	speed = linear_velocity.length()*Engine.get_frames_per_second()*3.6*delta
	traction(speed)
	$Hud/speed.text=str(round(speed))+"  KMPH"

	delta_time += delta
	local_velocity = lerp(((global_transform.origin - previous_global_position) / delta) * global_transform.basis, local_velocity, 0.5)
	previous_global_position = global_position

	process_throttle(delta)
	process_motor(delta)
	process_transmission(delta)

	# var fwd_mps = transform.basis.x.x
	steer_target = Input.get_action_strength("Steer Left") - Input.get_action_strength("Steer Right")
	steer_target *= STEER_LIMIT

	if Input.is_action_pressed("Full Throttle"):
		# Increase engine force at cost of wheel slip
		if speed < 30 and speed != 0:
			engine_force = -clamp(engine_force_value * 3, 0, 3000)
		else:
			engine_force = -clamp(engine_force_value * get_gear_ratio(current_gear), 0, 7000)
		print("Full throttle engine force: " + str(engine_force))
		full_throttle_amount = 0.1
		# Slip penalty
		$WheelFrontLeft.wheel_friction_slip=2
		$WheelFrontRight.wheel_friction_slip=2
		$WheelRearRight.wheel_friction_slip=0.2
		$WheelRearLeft.wheel_friction_slip=0.2

		# Roll influence penalty
		$WheelFrontLeft.wheel_roll_influence= 1
		$WheelFrontRight.wheel_roll_influence= 1
		$WheelRearRight.wheel_roll_influence= 0
		$WheelRearLeft.wheel_roll_influence = 0

	else:

		full_throttle_amount = 1.0
		$WheelFrontLeft.wheel_friction_slip=3
		$WheelFrontRight.wheel_friction_slip=3
		$WheelRearRight.wheel_friction_slip=3
		$WheelRearLeft.wheel_friction_slip=3

		$WheelFrontLeft.wheel_roll_influence=0.5
		$WheelFrontRight.wheel_roll_influence=0.5
		$WheelRearRight.wheel_roll_influence=0.5
		$WheelRearLeft.wheel_roll_influence=0.5
		engine_force = 0

	throttle_input = pow(Input.get_action_strength("Throttle"), 2.0)

	if Input.is_action_pressed("Throttle") and not Input.is_action_pressed("Full Throttle"):
		print("Throttle: " + str(throttle_input))
		# Increase engine force at low speeds to make the initial acceleration faster.
		if speed < 30 and speed != 0:
			engine_force = -clamp(engine_force_value * 2, 0, 3000)
		else:
			engine_force = -clamp(engine_force_value * get_gear_ratio(current_gear), 0, 7000)


	brake_input = Input.get_action_strength("Brakes")

	if Input.get_action_strength("Brakes"):
	# Increase engine force at low speeds to make the initial acceleration faster.
		# print("forwad velocity: ", str(global_transform.basis.z.dot(body.velocity)))
		if local_velocity.z < -0.1:
			brake = 1
		else:
			engine_force = clamp(engine_force_value, 0, 300)
	else:
		brake = 0

	if Input.is_action_pressed("Handbrake"):
		# brake front wheels
		$WheelFrontLeft.brake = 25
		$WheelFrontRight.brake = 25

		$WheelFrontLeft.wheel_friction_slip=0.9
		$WheelFrontRight.wheel_friction_slip=0.9
		$WheelRearRight.wheel_friction_slip=0.1
		$WheelRearLeft.wheel_friction_slip=0.1
	else:
		$WheelRearRight.wheel_friction_slip=3
		$WheelRearLeft.wheel_friction_slip=3

	steering = move_toward(steering, steer_target, STEER_SPEED)



func traction(speed):
	apply_central_force(Vector3.DOWN*speed)

func process_throttle(delta : float):
	var throttle_delta := throttle_speed * delta

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
	if new_rpm > (max_rpm ) or new_rpm <= idle_rpm:
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
#	print("Real wheel spin " + str(real_wheel_spin) + " ideal wheel spin " + str(ideal_wheel_spin) + " final drive " + str(final_drive))
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
				# print with 0 precision decimals place
				print("RPM: " + str(motor_rpm).pad_decimals(0) + " Ideal RPM: " + str(current_ideal_gear_rpm).pad_decimals(0) + " Speed: " + str(speed).pad_decimals(0))
				print("Current gear: " + str(current_gear))
				# calculate the shift rpm based on current gear: more gear means higher rpm to shift
				if current_ideal_gear_rpm > (max_rpm * (1 - ((1.0 / (1 + current_gear)) * full_throttle_amount))):
					if delta_time - last_shift_delta_time > shift_time:
						shift(1)
			elif current_gear == 0 and motor_rpm > clutch_out_rpm:
				shift(1)
		if current_gear - 1 > 0:
			if current_gear > 1 and previous_gear_rpm < 0.25 * max_rpm:
				if delta_time - last_shift_delta_time > shift_time:
					shift(-1)

	if absf(current_gear) <= 1 and brake_input > 0.7:
		if not reversing:
			if speed < 1.0 or local_velocity.z > 0.0:
				if delta_time - last_shift_delta_time > shift_time:
					shift(-1)
		else:
			if speed < 1.0 or local_velocity.z < 0.0:
				if delta_time - last_shift_delta_time > shift_time:
					shift(1)

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
		motor_rpm = lerpf(motor_rpm, requested_gear_rpm, 0.5)
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

