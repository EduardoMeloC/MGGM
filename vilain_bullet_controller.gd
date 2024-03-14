@tool
extends Node2D

enum patterns {
	None,
	Radial,
	Zombie,
	Ghost
}

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

@onready var _player = get_tree().get_nodes_in_group("Player")[0]
@onready var _pool = $BulletPool

@onready var _shoot_timer = $ShootTimer

var _current_pattern := patterns.Radial
var pattern_counter := 0

var rng = RandomNumberGenerator.new()
var rebound_chance : float = 0.05

var ghost_parent

func _draw():
	if Engine.is_editor_hint():
		draw_arc(Vector2.ZERO, _debug_radius, 0, deg_to_rad(_shoot_radius), 32, Color.BLUE, 4)
		var angle_step = deg_to_rad(_shoot_radius)/_bullet_count
		for i in range(_bullet_count+1):
			var dir = Vector2(cos(angle_step*i), sin(angle_step*i))
			draw_circle(dir*_debug_radius, 3, Color.WHITE)


func spawn_bullets_radial(bullet_count: int, shoot_radius: int, initial_direction:= Vector2.ZERO, is_faster := false):
	var player_direction = (_player.position - self.global_position).normalized() 
	var direction = player_direction if initial_direction == Vector2.ZERO else initial_direction
	var angle_step = deg_to_rad(shoot_radius)/bullet_count
	for i in range(-bullet_count/2, bullet_count/2):
		var dir = direction.rotated(i*angle_step).normalized()
		var bullet : Bullet = _pool.get_object().initialize(self.global_position, dir, Globals.BulletShape.circle, "red") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(self.global_position, dir, Globals.BulletShape.circle, "red", true)
		if is_faster:
			bullet.set_calculate_next_step(func(delta : float):
				return bullet.direction * 6.0)

func spawn_bullet_wall():	
	var direction = Vector2(-1, 0) #vai pra esquerda da tela
	var intervals = DisplayServer.screen_get_size().y/20
	for i in 10:
		if pattern_counter%2 == 0:
			var bullet : Bullet = _pool.get_object().initialize(Vector2(1520, i*2*intervals), direction, Globals.BulletShape.circle, "orange") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(Vector2(1520, i*2*intervals), direction, Globals.BulletShape.circle, "orange", true) 
		else:
			var bullet : Bullet = _pool.get_object().initialize(Vector2(1520, i*2*intervals + intervals/2), direction, Globals.BulletShape.circle, "orange") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(Vector2(1520, i*2*intervals + intervals/2), direction, Globals.BulletShape.circle, "orange", true)

func spawn_ghost():
	var direction = Vector2(-1, 0) #vai pra esquerda da tela
	var bullet : Bullet = _pool.get_object().initialize(self.global_position, direction, Globals.BulletShape.circle, "blue") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(self.global_position, direction, Globals.BulletShape.circle, "blue", true)
	bullet.set_calculate_next_step(func(delta : float):
		return bullet.direction * 10.0)
	ghost_parent = bullet
	var up_bullet : Bullet = _pool.get_object().initialize(self.global_position, direction.rotated(150.0).normalized(), Globals.BulletShape.circle, "blue") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(self.global_position, direction.rotated(150.0).normalized(), Globals.BulletShape.circle, "blue", true)
	var down_bullet : Bullet = _pool.get_object().initialize(self.global_position, direction.rotated(-150.0).normalized(), Globals.BulletShape.circle, "blue") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(self.global_position, direction.rotated(-150.0).normalized(), Globals.BulletShape.circle, "blue", true)

func spawn_ghost_collateral():
	var up_bullet : Bullet = _pool.get_object().initialize(ghost_parent.global_position, Vector2(0, -1), Globals.BulletShape.circle, "orange") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(ghost_parent.global_position, Vector2(0, -1), Globals.BulletShape.circle, "orange", true)
	var down_bullet : Bullet = _pool.get_object().initialize(ghost_parent.global_position, Vector2(0, 1), Globals.BulletShape.circle, "orange") if rng.randf() <= (1 - rebound_chance) else _pool.get_object(true).initialize(ghost_parent.global_position, Vector2(0, 1), Globals.BulletShape.circle, "orange", true)


####attack starters

func start_radial():
	_current_pattern = patterns.Radial
	pattern_counter = 10
	_shoot_timer.start(1.0)


func start_zombie():
	_current_pattern = patterns.Zombie
	pattern_counter = 10
	_shoot_timer.start(0.3)

func start_ghost():
	_current_pattern = patterns.Ghost
	pattern_counter = 15
	spawn_ghost()
	_shoot_timer.start(0.3)

####attack timer
func _on_shoot_timer_timeout():
	pattern_counter -= 1
	if pattern_counter >= 0: 
		match _current_pattern:
			patterns.Radial:
				spawn_bullets_radial(60, 180)
			patterns.Zombie:
				if pattern_counter > 5:
					spawn_bullet_wall()
				else:
					spawn_bullets_radial(20, 145, Vector2(-1, 0), true)
			patterns.Ghost:
				spawn_ghost_collateral()
				
	else:
		_shoot_timer.stop()
		_current_pattern = patterns.None
