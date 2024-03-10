@tool
class_name ZudeToolsCardVideo
extends ZudeToolsCard

#region Constants

const PLAY = preload("res://icons/play.svg")
const PAUSE = preload("res://icons/pause.svg")

#endregion

#region Onready Variables

@onready var label: Label = %Label
@onready var button: Button = %Button

@onready var video: VideoStreamPlayer = %Video
@onready var play_pause_button: Button = %PlayPauseButton
@onready var playback_slider: HSlider = %PlaybackSlider

#endregion

func _ready() -> void:
	play_pause_button.toggled.connect(toggle_playback)
	button.pressed.connect(toggle_playback)
	playback_slider.value_changed.connect(set_playback_position)
	button.focus_entered.connect(focus_changed)
	
	update_label()
	update_preview()
	update_video()
	
	playback_slider.max_value = video.get_stream_length()

func _exit_tree() -> void:
	if video.is_playing():
		video.stop()
	
	play_pause_button.toggled.disconnect(toggle_playback)
	button.pressed.disconnect(toggle_playback)
	button.focus_entered.disconnect(focus_changed)
	playback_slider.value_changed.disconnect(set_playback_position)

## Set the label node's text.
func update_label() -> void:
	name = title
	label.text = title
	tooltip_text = title

## Set the preview node's texture.
func update_preview(texture: Texture2D = Config.DEFAULT_PREVIEW) -> void:
	var image = Image.new()
	image.load(path)
	if image.is_empty() == false:
		texture = ImageTexture.create_from_image(image)
	
	button.icon = texture

## Set the video stream file to the path property.
func update_video() -> void:
	video.stream.file = path

## Update slider and preview texture each frame.
func track_playback() -> void:
	if playback_slider.value != video.stream_position:
		playback_slider.value = video.stream_position
	if video.is_playing() and video.paused == false:
		button.icon = video.get_video_texture()

## Set states based on the play pause button.
func toggle_playback() -> void:
	if video.is_playing():
		if video.paused:
			video.paused = false
			play_pause_button.icon = PAUSE
			track_playback()
		else:
			video.paused = true
			play_pause_button.icon = PLAY
	else:
		video.play()
		play_pause_button.icon = PAUSE
		track_playback()

## Set playback position via the slider.
func set_playback_position(value: float) -> void:
	video.stream_position = value
	if video.stream_position == video.get_stream_length():
		reset_playback()

## Stop playback and reset UI.
func reset_playback() -> void:
	video.stop()
	playback_slider.value = 0
	play_pause_button.icon = PLAY
	play_pause_button.button_pressed = false

## Receive focus state from the tab, stop playback when unfocused.
func tab_focused(is_focused: bool) -> void:
	if is_focused == false:
		reset_playback()
