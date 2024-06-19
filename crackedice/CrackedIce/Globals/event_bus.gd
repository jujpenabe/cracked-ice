extends Node

# Vehicle update events
signal speed_changed(new_speed)
signal max_rpm_changed(new_max_rpm)
signal rpm_changed(new_rpm)
signal gear_changed(new_gear: String)
signal car_hit_damage(impulse)
signal car_destroyed()
signal damage_made(damage_amount: float)
signal heat_applied(heat_amount: float)

# Vehicle request events
signal max_rpm_requested


# World update events
signal ambient_temperature_changed(new_temperature)

# World request events
signal ambient_temperature_requested

# UI update events
signal damagebar_setup(max_health)
signal damagebar_hit_health_changed(new_hit_health)
signal heat_changed(new_heat)