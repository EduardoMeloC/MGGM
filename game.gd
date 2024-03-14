extends Node2D

@onready var bgm = $BGM

func _ready():
	bgm.play(0.0)


func _input(event):	
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed:
		pass
