class_name ZudeToolsVideoPlayer
extends Control

#region Onready Variables

@onready var video: VideoStreamPlayer = %Video
@onready var play_pause_button: Button = %PlayPauseButton
@onready var playback_slider: HSlider = %PlaybackSlider

#endregion

func _ready() -> void:
	play_pause_button.toggled.connect(toggle_playback)

func _exit_tree() -> void:
	play_pause_button.toggled.disconnect(toggle_playback)

func toggle_playback(toggled_on: bool) -> void:
	if video.is_playing():
		if toggled_on:
			video.paused = false
		else:
			video.paused = true
	else:
		if toggled_on:
			video.play()

# FIXME - Video diemsnions are fucked
# TODO - Implement slider for playback control
