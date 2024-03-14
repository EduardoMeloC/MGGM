extends Node2D

@onready var bullet_controller = $BulletController

var animations = ["Float", "Attack", "Sugar Rush"]
var counter := 0


func _input(event):	
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_PAGEDOWN) and just_pressed:
		get_node("AnimationPlayer").play(animations[counter])
		counter += 1


func new_attack(index):
	get_parent().som_de_tiro_se_abaixa(load("res://resources/sound/sfx/menina.mp3"))
	if index == 1:
		bullet_controller.start_ribbon()
	elif index == 2:
		bullet_controller.start_constellation()
	elif index == 0:
		bullet_controller.start_radial()
