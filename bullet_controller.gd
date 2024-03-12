@tool
extends Node2D

enum patterns {
	None,
	Radial,
	Faster,
	Constellation,
	Ribbon
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

var _current_pattern := patterns.Constellation

var pattern_counter := 0
var theta = 0.0
var alpha := 1.3 #range = (0, 2*PI)

func _draw():
	if Engine.is_editor_hint():
		draw_arc(Vector2.ZERO, _debug_radius, 0, deg_to_rad(_shoot_radius), 32, Color.BLUE, 4)
		var angle_step = deg_to_rad(_shoot_radius)/_bullet_count
		for i in range(_bullet_count+1):
			var dir = Vector2(cos(angle_step*i), sin(angle_step*i))
			draw_circle(dir*_debug_radius, 3, Color.WHITE)


func spawn_bullets_radial(bullet_count: int, shoot_radius: int, initial_direction:= Vector2.ZERO):
	var player_direction = (_player.position - self.global_position).normalized() 
	var direction = player_direction if initial_direction == Vector2.ZERO else initial_direction
	var angle_step = deg_to_rad(shoot_radius)/bullet_count
	for i in range(-bullet_count/2, bullet_count/2):
		var dir = direction.rotated(i*angle_step).normalized()
		var bullet : Bullet = _pool.get_object().initialize(self.global_position, dir, Globals.BulletShape.circle, "red")

func spawn_bullets_faster(bullet_count: int, shoot_radius: int):
	var player_direction = (_player.position - self.global_position).normalized() 
	var angle_step = deg_to_rad(shoot_radius)/bullet_count
	for i in range(-bullet_count/2, bullet_count/2+1):
		var dir = player_direction.rotated(i*angle_step).normalized()
		var bullet : Bullet = _pool.get_object().initialize(self.global_position, dir)
		bullet.set_calculate_next_step(func(delta : float):
			return bullet.direction * 1.1)
			
func spawn_bullets_sine(horizontal_speed: float, frequency: float, amplitude: float, speed := 400):
	var player_direction = (_player.position - self.position).normalized() 
	var bullet : Bullet = _pool.get_object().initialize(self.global_position, player_direction, Globals.BulletShape.capsule, "orange")
	bullet.set_calculate_next_step(func(delta : float):
		var dir = Vector2(horizontal_speed, cos(bullet.time_alive*frequency)*amplitude)
		bullet.direction = dir
		var next_step = dir * speed * delta
		return next_step
	)

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_SPACE) and just_pressed:
		start_radial()
	if Input.is_key_pressed(KEY_F1) and just_pressed:
		spawn_bullets_faster(64, 64)
	if Input.is_key_pressed(KEY_F2) and just_pressed:
		spawn_bullets_sine(1, 2, 2)
		spawn_bullets_sine(1, 2, -2)
	if Input.is_key_pressed(KEY_0) and just_pressed:
		start_constellation()
	if Input.is_key_pressed(KEY_1) and just_pressed:
		start_ribbon()

#constellation
func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))

func spawn_constellation(shoot_radius: int, bullet_count: int):
	var angle_step = deg_to_rad(shoot_radius)/bullet_count
	var dir = get_vector(theta)
	var bullet : Bullet = _pool.get_object().initialize(self.global_position, dir, Globals.BulletShape.circle, "green")


####attack starters
#Essas funções só vão ser chamadas uma vez, quando a magical girl selecionar esse ataque pra jogar
#Servem pra settar o timer, o número de ataques e o tipo do ataque que vai servir para o timer saber
#que função chamar
#No caso do constellation a função cria uma bala só, então é chamada 180 vezes e a cada 0.1 segundos
#No caso do radial ela cria uma onda por chamada de função, então chama 10 vezes e a cada 1 segundo

func start_constellation():
	pattern_counter = 180
	_current_pattern = patterns.Constellation
	spawn_constellation(64, 64)
	_shoot_timer.start(0.1)

func start_radial():
	_current_pattern = patterns.Radial
	pattern_counter = 10
	_shoot_timer.start(1.0)

func start_ribbon():
	_current_pattern = patterns.Ribbon
	pattern_counter = 60
	_shoot_timer.start(0.4)

####attack timer
#Rola quando o timer termina, ele automaticamente vai recomeçar até que o contador chegue a -1,
#quando ele vai mandar o timer parar de rodar.
#Alguns ataques têm mais de um padrão e precisam de modal para atirar os outros padrões periodicamente,
#Nesse caso o radial spawna 4 vezes na constelação e o faster 2 vezes no radial
func _on_shoot_timer_timeout():
	pattern_counter -= 1
	if pattern_counter >= 0: 
		match _current_pattern:
			patterns.Constellation:
				if pattern_counter%45 == 0:
					spawn_bullets_radial(64, 64)
				spawn_constellation(64, 64)
			patterns.Radial:
				spawn_bullets_radial(60, 180)
			patterns.Ribbon:
				if pattern_counter % 5 == 0:
					spawn_bullets_radial(16, 60, Vector2.RIGHT.rotated(deg_to_rad(randi_range(-10, 10))))
					spawn_bullets_radial(320, 320, Vector2.LEFT)
					
					spawn_bullets_sine(1, 2, 2)
					spawn_bullets_sine(1, 2, -2)
				else:
					spawn_bullets_sine(1, 2, 2)
					spawn_bullets_sine(1, 2, -2)
					
	else:
		_shoot_timer.stop()
		_current_pattern = patterns.None
