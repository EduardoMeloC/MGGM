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
	print("INDEX:             " + str(index))
	if index <= 9:
		bullet_controller.start_ribbon()
	elif index <= 19:
		bullet_controller.start_constellation()
	elif index <= 24:
		bullet_controller.start_radial()
