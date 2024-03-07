class_name Bullet
extends Sprite2D

const SHAPE := preload("./resources/bullet_collision_shape.tres")

var query := PhysicsShapeQueryParameters2D.new()
@onready var direct_space_state := get_world_2d().direct_space_state

@export var direction := Vector2.ZERO
@export var speed := 256.0
@export var max_distance := 2048.0

var direction_over_time := func(direction: Vector2, delta: float):
	return direction
	
func set_direction_over_time(f := func(direction: Vector2, delta: float): return direction):
	self.direction_over_time = f

var _travelled_distance := 0.0

func _init() -> void:
	query.shape = SHAPE
	query.collide_with_areas = true
	query.collision_mask = 1
	self.top_level = true
	
func initialize(position: Vector2, direction:Vector2, direction_over_time:=func(direction:Vector2, delta:float): return direction):
	self.position = position
	self.direction = direction.normalized()
	self.look_at(position+self.direction)
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	self._travelled_distance = 0.0
	self.direction_over_time = direction_over_time
	return self
	
func deactivate():
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
func _process(delta: float) -> void:
	self.direction = direction_over_time.call(self.direction, delta)
	var next_step = self.direction * self.speed * delta
	self.position += next_step
	_travelled_distance += next_step.length()
	query.transform = self.global_transform

	if _travelled_distance > max_distance:
		deactivate()
	
	var collision_result := direct_space_state.intersect_shape(query, 1)
	if collision_result:
		deactivate()
