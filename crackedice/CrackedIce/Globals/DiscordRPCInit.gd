extends Node

func _ready():
  DiscordRPC.app_id = 1233487510290825278 # Application ID
  DiscordRPC.details = "Testing alpha game"
  DiscordRPC.state = "Checkpoint 23/23"

  DiscordRPC.large_image = "crackedicecover1" # Image key from "Art Assets"
  DiscordRPC.large_image_text = "Coming Soon!"
  DiscordRPC.small_image = "editing_yellow_2" # Image key from "Art Assets"
  DiscordRPC.small_image_text = "Editing Opening and Main Menu"

  DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
  # DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

  DiscordRPC.refresh() # Always refresh after changing the values!