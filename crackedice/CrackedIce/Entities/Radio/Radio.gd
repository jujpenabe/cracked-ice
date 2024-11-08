extends Control

@export var stations: Array[RadioStation] = []

var current_station_index: int = 0

var tween : Tween

var tmp_audio_stream_player : AudioStreamPlayer

func _ready() -> void:
	# turn on the radio
	radio_on(current_station_index)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_radio_station_down"):
		current_station_index = (current_station_index + 1) % stations.size()
		radio_on(current_station_index) # TODO: Store the playback position to restore it

	if Input.is_action_just_pressed("change_radio_station_up"):
		current_station_index = (current_station_index - 1) % stations.size()
		radio_on(current_station_index) # TODO: Store the playback position to restore it

func radio_on(station_index: int = 0) -> void:
	# play the first song
	# ProjectMusicController.build_music_stream_player(stations[station_index].songs[0])
	# ProjectMusicController.fade_in(0.5)

	# play a random song
	var song_index = randi() % stations[station_index].songs.size()
	tmp_audio_stream_player = ProjectMusicController.play_stream(stations[station_index].songs[song_index])

	%StationIcon.texture = stations[station_index].icon
	# set the icon to alpha 0
	%StationIcon.modulate.a = 0.0
	tween = create_tween()
	tween.tween_property(%StationIcon, "modulate:a", 1.0, 0.7)
	# wait 3 second
	tween.tween_interval(3.0)
	# fade out
	tween.tween_property(%StationIcon, "modulate:a", 0.0, 0.7)
