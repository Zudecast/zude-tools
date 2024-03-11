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
	
	pressed.connect(toggle_playback)
	transport.play_pause_button.toggled.connect(toggle_playback)
	transport.playback_slider.value_changed.connect(set_playback_position)

func _exit_tree() -> void:
	super()
	
	pressed.disconnect(toggle_playback)
	transport.play_pause_button.toggled.disconnect(toggle_playback)
	transport.playback_slider.value_changed.disconnect(set_playback_position)
	
	if video.is_playing():
		video.stop()

## Receive focus state from the tab, stop playback when unfocused.
func tab_focused(is_focused: bool) -> void:
	if is_focused == false:
		reset_playback()

## Set the video stream file to the path property.
func update_video() -> void:
	video.stream.file = path

## Update slider and preview texture each frame.
func track_playback() -> void:
	if transport.playback_slider.value != video.stream_position:
		transport.playback_slider.value = video.stream_position
	if video.is_playing() and video.paused == false:
		icon = video.get_video_texture()
		focus_changed()

## Set states based on the play pause button.
func toggle_playback() -> void:
	if video.is_playing():
		if video.paused:
			video.paused = false
			transport.play_pause_button.icon = PAUSE
			track_playback()
		else:
			video.paused = true
			transport.play_pause_button.icon = PLAY
	else:
		video.play()
		transport.play_pause_button.icon = PAUSE
		track_playback()

## Set playback position via the slider.
func set_playback_position(value: float) -> void:
	video.stream_position = value
	toggle_playback()
	if video.stream_position == video.get_stream_length():
		reset_playback()

## Stop playback and reset UI.
func reset_playback() -> void:
	video.stop()
	transport.playback_slider.value = 0
	transport.play_pause_button.icon = PLAY
	transport.play_pause_button.button_pressed = false


