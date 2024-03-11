@tool
class_name ZudeToolsCardVideo
extends ZudeToolsCard

#region Constants

const PLAY: CompressedTexture2D = preload("res://icons/play.svg")
const PAUSE: CompressedTexture2D = preload("res://icons/pause.svg")
const TRANSPORT: PackedScene = preload("res://scenes/transport/transport_controls.tscn")

#endregion

#region Onready Variables

@onready var video = VideoStreamPlayer.new()
@onready var stream = FFmpegVideoStream.new()
@onready var transport: ZudeToolsVideoTransport = TRANSPORT.instantiate()

#endregion

func _ready() -> void:
	super()
	
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	video.stream = stream
	
	update_video()
	add_child(video)
	video.visible = false
	
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

## Receive focus state from the tab, stop playback when unfocused.
func tab_focused(is_focused: bool) -> void:
	if is_focused == false:
		end_playback()

## Set the video stream file to the path property.
func update_video() -> void:
	video.stream.file = path

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
	video.set_stream_position(value)
	toggle_playback()
	if video.stream_position == video.get_stream_length():
		end_playback()



