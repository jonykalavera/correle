extends AudioStreamPlayer


const INTRO = 0
const INTRO_END = 4.55
const LOOP_START = 21.5
const LOOP_END = 89.2
const state = INTRO
var played_intro = false
func start():
	if played_intro and not playing:
		play(INTRO_END)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_stream_playback():
		var position = get_playback_position() + AudioServer.get_time_since_last_mix()
		if position > INTRO_END and not played_intro:
			played_intro = true
			stop()
		if position > LOOP_END:
			seek(LOOP_START)

	
