extends AnimatedSprite2D

const BulletData = {
	Globals.BulletShape.circle: {
		"shape": preload("./bullet_circle_shape.tres"),
		"rebound": preload("./bullet_circle_rebound.tres"),
		"animation": "circle"
	},
	Globals.BulletShape.capsule: {
		"shape": preload("./bullet_capsule_shape.tres"),
		"rebound": preload("./bullet_capsule_rebound.tres"),
		"animation": "capsule"
	},
	Globals.BulletShape.rectangle: {
		"shape": preload("./bullet_rectangle_shape.tres"),
		"rebound": preload("./bullet_rectangle_rebound.tres"),
		"animation": "rectangle"
	},
	Globals.BulletShape.double: {
		"shape": preload("./bullet_double_shape.tres"),
		"rebound": preload("./bullet_double_rebound.tres"),
		"animation": "double"
	},
	Globals.BulletShape.big: {
		"shape": preload("./bullet_big_shape.tres"),
		"rebound": preload("./bullet_big_rebound.tres"),
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

@export var direction : Vector2 :
	set(value): 
		self.look_at(position + direction)
		direction = value
@export var speed := 256.0
@export var max_distance := 8192.0
@export var max_time_alive := 30

var travelled_distance := 0.0
var time_alive := 0.0

var direction_over_time := func(direction: Vector2, delta: float):
	return direction
	
var calculate_next_step := func(delta: float): 
	return self.direction * self.speed * delta
	
func set_calculate_next_step(f := func(delta: float): return self.direction * self.speed * delta):
	self.calculate_next_step = f

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var next_step = calculate_next_step.call(delta)
	self.position += next_step
	travelled_distance += next_step.length()
	time_alive += delta
	
	if travelled_distance > max_distance or time_alive > max_time_alive:
		queue_free()
	
	pass
