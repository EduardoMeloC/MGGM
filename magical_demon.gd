extends Node2D

@onready var bullet_controller = $BulletController

func new_attack(index):
	print("INDEX:             " + str(index))
	if index <= 9:
		bullet_controller.start_ghost()
	elif index <= 19:
		bullet_controller.start_zombie()
	elif index <= 24:
		bullet_controller.start_radial()
