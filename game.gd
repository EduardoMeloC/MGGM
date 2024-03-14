extends Node2D

@onready var bgm = $BGM
@onready var audio = $AudioStreamPlayer
@onready var turn_timer = $TurnTimer

var current_attacker
var current_turn = 0
var rng = RandomNumberGenerator.new()

@onready var magical_girl = $MagicalGirl
@onready var villain = $MagicalDemon

func _ready():
	bgm.play(0.0)
	turn_timer.start(4.0)
	current_attacker = magical_girl

func _input(event):	
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed:
		pass


func _on_turn_timer_timeout():
	current_turn += 1
	if current_turn < 10:
		var numero = rng.randi_range(0, 2)
		current_attacker.new_attack(numero)
	elif current_turn == 12:
		current_turn = 0
		if current_attacker == magical_girl:
			current_attacker = villain
		else:
			current_attacker = magical_girl

func som_de_tiro_se_abaixa(som):
	audio.set_stream(som)
	audio.play()

func _on_bgm_finished():
	bgm.set_stream(load("res://resources/sound/Urban-Airspace-Magic-Battlefield-Dance-loop.ogg"))
	bgm.play(0.0)
