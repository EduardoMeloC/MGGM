class_name Bullet
extends Sprite2D

const SHAPE := preload("./resources/bullet_collision_shape.tres")

var query := PhysicsShapeQueryParameters2D.new()
@onready var direct_space_state := get_world_2d().direct_space_state

@export var direction : Vector2 :
	set(value): 
		self.look_at(position + direction)
		direction = value
@export var speed := 256.0
@export var max_distance := 2048.0
@export var max_time_alive := 5

var direction_over_time := func(direction: Vector2, delta: float):
	return direction
	
var calculate_next_step := func(delta: float): 
	return self.direction * self.speed * delta
	
func set_calculate_next_step(f := func(delta: float): return self.direction * self.speed * delta):
	self.calculate_next_step = f

var travelled_distance := 0.0
var time_alive := 0.0

func _init() -> void:
	query.shape = SHAPE
	query.collide_with_areas = true
	query.collision_mask = 1
	self.top_level = true
	
func initialize(position: Vector2, direction:Vector2, calculate_next_step:=func(delta: float): return self.direction * self.speed * delta):
	self.position = position
	self.direction = direction.normalized()
	self.look_at(position+self.direction)
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	self.travelled_distance = 0.0
	self.time_alive = 0.0
	self.calculate_next_step = calculate_next_step
	return self
	
func deactivate():
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
func _process(delta: float) -> void:
	var next_step = calculate_next_step.call(delta)
	self.position += next_step
	travelled_distance += next_step.length()
	time_alive += delta
	query.transform = self.global_transform

	if travelled_distance > max_distance or time_alive > max_time_alive:
		deactivate()
	
	var collision_result := direct_space_state.intersect_shape(query, 1)
	if collision_result:
		deactivate()
