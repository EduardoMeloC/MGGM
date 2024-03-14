class_name Bullet
extends AnimatedSprite2D

const BulletData = {
	Globals.BulletShape.circle: {
		"shape": preload("./resources/bullet_circle_shape.tres"),
		"rebound": preload("./resources/bullet_circle_rebound.tres"),
		"animation": "circle"
	},
	Globals.BulletShape.capsule: {
		"shape": preload("./resources/bullet_capsule_shape.tres"),
		"rebound": preload("./resources/bullet_capsule_rebound.tres"),
		"animation": "capsule"
	},
	Globals.BulletShape.rectangle: {
		"shape": preload("./resources/bullet_rectangle_shape.tres"),
		"rebound": preload("./resources/bullet_rectangle_rebound.tres"),
		"animation": "rectangle"
	},
	Globals.BulletShape.double: {
		"shape": preload("./resources/bullet_double_shape.tres"),
		"rebound": preload("./resources/bullet_double_rebound.tres"),
		"animation": "double"
	},
	Globals.BulletShape.big: {
		"shape": preload("./resources/bullet_big_shape.tres"),
		"rebound": preload("./resources/bullet_big_rebound.tres"),
		"animation": "big"
	},
}

const ColorShift = {
	"red": 0.0,
	"orange": 0.083,
	"yellow": 0.167,
	"green": 0.333,
	"cyan": 0.5,
	"blue": 0.667,
	"magenta": 0.833,
	"pink": 0.917,
}

var query := PhysicsShapeQueryParameters2D.new()

@onready var direct_space_state := get_world_2d().direct_space_state

@export var direction : Vector2 :
	set(value): 
		self.look_at(position + direction)
		direction = value
@export var speed := 256.0
@export var max_distance := 8192.0
@export var max_time_alive := 30

var direction_over_time := func(direction: Vector2, delta: float):
	return direction
	
var calculate_next_step := func(delta: float): 
	return self.direction * self.speed * delta
	
func set_calculate_next_step(f := func(delta: float): return self.direction * self.speed * delta):
	self.calculate_next_step = f

var travelled_distance := 0.0
var time_alive := 0.0

func _init() -> void:
	query.collide_with_areas = true
	query.collision_mask = 1
	self.top_level = true
	
var instanced_color
var instanced_shape : Globals.BulletShape

func initialize(position: Vector2, direction:Vector2, shape:= Globals.BulletShape.circle, color := "red", color_is_negative := false):
	instanced_shape = shape	
	instanced_color = color
	
	self.position = position
	self.direction = direction.normalized()
	self.look_at(position+self.direction)
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	self.travelled_distance = 0.0
	self.time_alive = 0.0
	self.animation = BulletData[shape]["animation"]
	self.material.set("shader_parameter/hue_shift", ColorShift[color])
	if color_is_negative:
		var rebound_box = $Area2D/CollisionShape2D
		rebound_box.shape = BulletData[shape]["shape"]
		self.material.set("shader_parameter/is_negative", true)
	query.shape = BulletData[shape]["shape"]
	return self
	
func deactivate():
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	return self
	
func _process(delta: float) -> void:
	var next_step = calculate_next_step.call(delta)
	self.position += next_step
	travelled_distance += next_step.length()
	time_alive += delta
	query.transform = self.global_transform.rotated_local(90)
	if travelled_distance > max_distance or time_alive > max_time_alive:
		deactivate()
	
	var collision_result := direct_space_state.intersect_shape(query, 1)
	if collision_result:
		deactivate()

