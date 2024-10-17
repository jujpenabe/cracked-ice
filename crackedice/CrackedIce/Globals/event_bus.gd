extends Node

# Vehicle update events
signal engine_started()
signal speed_changed(new_speed)
signal max_rpm_changed(new_max_rpm)
signal rpm_changed(new_rpm)
signal gear_changed(new_gear: String)
signal car_hit_damage(impulse)
signal car_destroyed()
signal damage_made(damage_amount: float)
signal heat_zone_assigned(heat_amount: float, source_pos : Vector3)
signal heat_zone_removed()
signal slip_bonus_changed(new_slip_bonus: float)
signal throtle_bonus_changed(new_throtle_bonus: float)
signal throtle_in()
signal throtle_out()
signal combat_started()
signal out_of_combat()

# Vehicle request events
signal max_rpm_requested


# UI update events
signal damagebar_setup(max_health)
signal damagebar_hit_health_changed(new_hit_health)
signal heat_changed(new_heat)
signal screen_fade_changed(target_alpha: float, duration: float)
# Game Events
signal game_started()
signal game_paused()
signal game_resumed()
signal game_over()