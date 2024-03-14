extends Node2D

@onready var bullet_controller = $BulletController

func new_attack(index):
	get_parent().som_de_tiro_se_abaixa(load("res://resources/sound/sfx/monstro.mp3"))
	if index == 1:
		bullet_controller.start_ghost()
	elif index == 2:
		bullet_controller.start_zombie()
	elif index == 0:
		bullet_controller.start_radial()
