@tool
class_name ZudeToolsCardVideo
extends ZudeToolsCard

#region Constants

const PLAY: CompressedTexture2D = preload("res://icons/play.svg")
const PAUSE: CompressedTexture2D = preload("res://icons/pause.svg")
const TRANSPORT: PackedScene = preload("res://scenes/transport/transport_controls.tscn")

#endregion

#region Onready Variables

@onready var video := VideoStreamPlayer.new()
@onready var stream := FFmpegVideoStream.new()
@onready var transport: ZudeToolsVideoTransport = TRANSPORT.instantiate()

#endregion

func _ready() -> void:
	super()
	
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	stream.file = path
	video.stream = stream
	video.visible = false
	add_child(video)
	
	margin.add_child(transport)
	transport.playback_slider.max_value = video.get_stream_length()
	transport.playback_slider.value = video.stream_position
	
	pressed.connect(toggle_playback)
	focus_exited.connect(end_playback)
	transport.play_pause_button.pressed.connect(toggle_playback)
	transport.playback_slider.value_changed.connect(set_playback_position)

func _exit_tree() -> void:
	super()
	
	pressed.disconnect(toggle_playback)
	focus_exited.disconnect(end_playback)
	transport.play_pause_button.pressed.disconnect(toggle_playback)
	transport.playback_slider.value_changed.disconnect(set_playback_position)
	
	if video.is_playing():
		video.stop()

## Receive visibility state from the parent tab. Stop playback when tab is not visible.
func tab_visible(visibility: bool) -> void:
	if visibility == false:
		end_playback()

## play stream from beginning.
func begin_playback() -> void:
	video.play()
	transport.play_pause_button.icon = PAUSE
	preview.texture = video.get_video_texture()
	transport.playback_slider.value = video.stream_position
	focus_changed()

## Pause playback and set play_pause icon.
func pause_playback() -> void:
	video.paused = true
	transport.play_pause_button.icon = PLAY

## Unpause playback and set play_pause icon.
func unpause_playback() -> void:
	video.paused = false
	transport.play_pause_button.icon = PAUSE

## Stop playback and reset UI.
func end_playback() -> void:
	video.stop()
	transport.play_pause_button.icon = PLAY
	transport.play_pause_button.button_pressed = false

## Set states based on the play pause button.
func toggle_playback() -> void:
	if video.is_playing():
		if video.paused:
			unpause_playback()
		else:
			pause_playback()
	else:
		begin_playback()

## Set playback position via the slider.
func set_playback_position(value: float) -> void:
	toggle_playback()
	video.set_stream_position(value)
