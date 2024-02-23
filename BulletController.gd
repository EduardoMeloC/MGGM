extends Node2D

const LinearBullet = preload("res://linear_bullet.tscn")

func spawn_bullets():
	var n_bullets = 180
	for i in range(n_bullets):
		var bullet = LinearBullet.instantiate()
		bullet.direction = Vector2(cos(2*PI/n_bullets*i), sin(2*PI/n_bullets*i))
		self.add_child(bullet)


func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_SPACE) and just_pressed:
		spawn_bullets()
