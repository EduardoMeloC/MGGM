extends Node2D

class_name player

@export var speed : float = 500;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_dir = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	var next_pos = position + input_dir.normalized() * speed * delta
	
	position = next_pos
		
		

func _on_bullet_hit():
	position = Vector2.ZERO
	print("die")

func _on_hitbox_enter(area : Area2D):
	var game_object = area.get_parent()
	if game_object.is_in_group("Bullet"):
		_on_bullet_hit()
