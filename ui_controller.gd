extends Control

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


@onready var pause_menu = $PauseContainer

@onready var audio = $"../AudioStreamPlayer"

func _ready():
	$PauseContainer/VBoxContainer/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index('Music')))
	$PauseContainer/VBoxContainer/SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index('SFX')))
	SceneManager.validate_scene("main_menu")
	SceneManager.validate_pattern(fade_out_pattern)
	SceneManager.validate_pattern(fade_in_pattern)

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_action_pressed("pause") and just_pressed:
		get_tree().paused = !get_tree().paused
		pause_menu.visible = !pause_menu.visible


func _on_resume_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	audio.set_stream(load("res://resources/sound/sfx/botoes_menu.mp3"))
	audio.play(0.0)

func _on_main_menu_pressed():
	SceneManager.change_scene("main_menu", fade_out_options, fade_in_options, general_options)
	get_tree().paused = false
	audio.set_stream(load("res://resources/sound/sfx/botoes_menu.mp3"))
	audio.play(0.0)


func _on_sfx_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_music_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
