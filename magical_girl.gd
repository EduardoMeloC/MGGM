extends Node2D


var animations = ["Float", "Attack", "Sugar Rush"]
var counter := 0

enum patterns {
	None,
	Radial,
	Faster,
	Constellation
}

var rng = RandomNumberGenerator.new()

func _ready():
	var my_random_number = rng.randi_range(0, 10)

func _input(event):	
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_PAGEDOWN) and just_pressed:
		get_node("AnimationPlayer").play(animations[counter])
		counter += 1


func _process(delta):
	pass
