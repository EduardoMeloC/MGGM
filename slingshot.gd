extends Node2D

class_name Slingshot

@onready var sprite := $Sprite2D
@onready var rect : ColorRect = $StrengthRect

var is_mouse_over = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var x = 0
func _process(delta):
	x += delta
	var wave = (-1 * abs(cos(x * PI/2)) + 1)
	var zigzag = (1 / PI) * acos(cos(PI * x))
	var y = wave*zigzag*zigzag
	rect.set_size(Vector2(20, y * 120))
	rect.color = Color.DARK_RED.lerp(Color.GREEN_YELLOW, y)


func _on_mouse_entered():
	is_mouse_over = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited():
	is_mouse_over = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
