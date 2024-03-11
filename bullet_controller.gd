@tool
extends Node2D

enum patterns {
	None,
	Radial,
	Faster,
	Constellation
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


func spawn_bullets_radial():
	var player_direction = (_player.position - self.global_position).normalized() 
	var angle_step = deg_to_rad(_shoot_radius)/_bullet_count
	for i in range(-_bullet_count/2, _bullet_count/2+1):
		var dir = player_direction.rotated(i*angle_step).normalized()
		var bullet : Bullet = _pool.get_object().initialize(self.global_position, dir)



func spawn_bullets_faster():
	var player_direction = (_player.position - self.global_position).normalized() 
	var angle_step = deg_to_rad(_shoot_radius)/_bullet_count
	for i in range(-_bullet_count/2, _bullet_count/2+1):
		var dir = player_direction.rotated(i*angle_step).normalized()
		var bullet : Bullet = _pool.get_object().initialize(self.global_position, dir)
		bullet.set_direction_over_time(func(direction : Vector2, delta : float):
			return direction * 1.01)



func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_SPACE) and just_pressed:
		start_radial()
	if Input.is_key_pressed(KEY_0) and just_pressed:
		start_constellation()

#constellation
func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))

func spawn_constellation():
	var angle_step = deg_to_rad(_shoot_radius)/_bullet_count
	var dir = get_vector(theta)
	var bullet : Bullet = _pool.get_object().initialize(self.global_position, dir)


####attack starters
#Essas funções só vão ser chamadas uma vez, quando a magical girl selecionar esse ataque pra jogar
#Servem pra settar o timer, o número de ataques e o tipo do ataque que vai servir para o timer saber
#que função chamar
#No caso do constellation a função cria uma bala só, então é chamada 180 vezes e a cada 0.1 segundos
#No caso do radial ela cria uma onda por chamada de função, então chama 10 vezes e a cada 1 segundo

func start_constellation():
	pattern_counter = 180
	_current_pattern = patterns.Constellation
	spawn_constellation()
	_shoot_timer.start(0.1)

func start_radial():
	_current_pattern = patterns.Radial
	pattern_counter = 10
	spawn_bullets_radial()
	_shoot_timer.start(1.0)


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
					spawn_bullets_radial()
				spawn_constellation()
			patterns.Radial:
				if pattern_counter%4 == 0:
					spawn_bullets_faster()
				else:
					spawn_bullets_radial()
	else:
		_shoot_timer.stop()
		_current_pattern = patterns.None
