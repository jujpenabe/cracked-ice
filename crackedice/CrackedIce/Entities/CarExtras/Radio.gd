extends Control


# Script for the radio UI
# TODO: Add audio and visual feedback for when the radio is on or off

@export var stations : Array[RadioStation] = [] 

var current_station_index : int = 0

func _ready() -> void:

	# turn on the radio
	radio_on()

func radio_on(station_index : int = 0) -> void:
	# display the radio icon on the UI
	%StationIcon.texture = stations[station_index].icon