@tool
extends Node2D

const LinearBullet = preload("res://linear_bullet.tscn")

@onready var _player = get_tree().get_nodes_in_group("Player")[0]

@export_range(0, 360) var _shoot_radius : int = 60:
	set(new_value):
		_shoot_radius = new_value
		queue_redraw()
		
@export_range(0, 360) var _bullet_count : int = 10:
	set(new_value):
		_bullet_count = new_value
		queue_redraw()
		
@export var _debug_radius : int = 80:
	set(new_value):
		_debug_radius = new_value
		queue_redraw()

var player_direction := Vector2.ONE
		
func _draw():
	if Engine.is_editor_hint():
		draw_arc(Vector2.ZERO, _debug_radius, 0, deg_to_rad(_shoot_radius), 32, Color.BLUE, 4)
		var angle_step = deg_to_rad(_shoot_radius)/_bullet_count
		for i in range(_bullet_count+1):
			var dir = Vector2(cos(angle_step*i), sin(angle_step*i))
			draw_circle(dir*_debug_radius, 3, Color.WHITE)

func spawn_bullets_radial():
	player_direction = (_player.position - self.position).normalized() 
	queue_redraw()
	var angle_step = deg_to_rad(_shoot_radius)/_bullet_count
	for i in range(-_bullet_count/2, _bullet_count/2+1):
		var dir = player_direction.rotated(i*angle_step).normalized()
		var bullet = LinearBullet.instantiate()
		bullet.direction = dir
		bullet.look_at(dir)
		self.add_child(bullet)


func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_SPACE) and just_pressed:
		spawn_bullets_radial()
