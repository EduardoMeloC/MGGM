extends Node2D

@export var fade_out_speed: float = 1.0
@export var fade_in_speed: float = 1.0
@export var fade_out_pattern: String = "fade"
@export var fade_in_pattern: String = "fade"
@export var fade_out_smoothness = 0.1 # (float, 0, 1)
@export var fade_in_smoothness = 0.1 # (float, 0, 1)
@export var fade_out_inverted: bool = false
@export var fade_in_inverted: bool = false
@export var color: Color = Color(0, 0, 0)
@export var timeout: float = 0.0
@export var clickable: bool = false
@export var add_to_back: bool = true

@onready var fade_out_options = SceneManager.create_options(fade_out_speed, fade_out_pattern, fade_out_smoothness, fade_out_inverted)
@onready var fade_in_options = SceneManager.create_options(fade_in_speed, fade_in_pattern, fade_in_smoothness, fade_in_inverted)
@onready var general_options = SceneManager.create_general_options(color, timeout, clickable, add_to_back)

const _resolution_options : Array[Vector2] = [
	Vector2i(427, 240),
	Vector2i(860, 480),
	Vector2i(960, 540),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]
const _default_resolution_index = 3

@onready var _camera : Camera2D = $Camera

@onready var play_button : Button = $Control/ButtonsContainer/VBoxContainer/PlayButton
@onready var settings_button : Button = $Control/ButtonsContainer/VBoxContainer/SettingsButton
@onready var exit_button : Button = $Control/ButtonsContainer/VBoxContainer/ExitButton
@onready var return_button : Button = $Control/ReturnButton

@onready var resolution_menu : OptionButton = $Control/SettingsContainer/VBoxContainer/ResolutionContainer/ResolutionOptions

@onready var audio = $AudioStreamPlayer

@export var button_hover_audio : AudioStream
@export var button_click_audio : AudioStream


func _ready():
	_add_resolution_options()
	var fade_in_first_scene_options = SceneManager.create_options(1, "fade")
	var first_scene_general_options = SceneManager.create_general_options(Color(0, 0, 0), 1, false)
	SceneManager.show_first_scene(fade_in_first_scene_options, first_scene_general_options)
	SceneManager.validate_scene("game")
	SceneManager.validate_pattern(fade_out_pattern)
	SceneManager.validate_pattern(fade_in_pattern)

func _on_play_button_pressed():
	print("play pressed")
	SceneManager.change_scene("game", fade_out_options, fade_in_options, general_options)


func _on_settings_button_pressed():
	var tween : Tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_camera, "position", Vector2(1280, 0), 0.5)
	return_button.position = Vector2(-100, 17)
	tween.tween_property(return_button, "position", Vector2(1280+60, 30), 0.5)

func _on_return_button_pressed():
	var tween : Tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_camera, "position", Vector2.ZERO, 0.5)
	tween.tween_property(return_button, "position", Vector2(3000, 30), 0.5)

func _on_exit_button_pressed():
	get_tree().quit()


func _on_button_hover():
	audio.stream = button_hover_audio
	audio.play()

func _add_resolution_options():
	for option in _resolution_options:
		resolution_menu.add_item("%dx%d" % [option.x, option.y])
	resolution_menu.select(_default_resolution_index)

func _on_resolution_options_item_selected(index):
	var window_size = _resolution_options[index]
	var screen_size = DisplayServer.screen_get_size()
	var screen_center = Vector2(screen_size.x / 2 - window_size.x / 2, screen_size.y / 2 - window_size.y / 2)
	DisplayServer.window_set_size(window_size)
	DisplayServer.window_set_position(screen_center)





func _on_fullscreen_toggled(button_pressed):
	if(button_pressed):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_vsync_toggled(button_pressed):
	if(button_pressed):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_sfx_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_music_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
