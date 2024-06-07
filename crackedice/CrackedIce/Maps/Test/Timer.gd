extends RichTextLabel

@export var time: float = 60.0
var playing: bool = false

func _ready():
	# set timer to 1 minute
	time = 60.0

func _process(delta):

	# update timer
	if playing:
		time -= delta
		if time > 60.0 and time < 60.2:
			playing = false
			time = 60.0
		# get the unique reference for the timer as rich text label
		text = "[center]%02d:%02d" % [floor(time / 60), floor(fmod(time, 60))] + "[/center]"
	else:
		text = "[center]press T to start[/center]"

	if time <= 0.0:
		playing = false
		time = 0.0
		text = "[center]00:00 press T to restart[/center]"
	# start timer when the button "t" is pressed
	if Input.is_physical_key_pressed(KEY_T):
		if playing and time < 59.0 or time == 0.0:
			time = 60.5
		elif time == 60.0 and not playing:
			text = "[center]Go![/center]"
			time = 60.0
			playing = true
	# reload scene when the button "r" is pressed
	