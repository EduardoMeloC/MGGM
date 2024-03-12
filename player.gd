extends Node2D

class_name player

@export var speed : float = 500;
@export var focused_speed : float = 200;


func _process(delta):
	var input_dir = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	var speed_multiplier = focused_speed if Input.is_action_pressed("focus_movement") else speed
	var next_pos = position + input_dir.normalized() * speed_multiplier * delta
	position = next_pos
	
func _on_bullet_hit():
	position = Vector2.ZERO
	print("die")
