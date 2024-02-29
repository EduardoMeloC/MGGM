extends Bullet
class_name LinearBullet

var _travelled_distance := 0

func _ready():
	direction = direction.normalized()


func _process(delta):
	var next_step = direction * speed * delta
	position += next_step
	_travelled_distance += next_step.length()

	if _travelled_distance > max_distance:
		queue_free()

func _on_player_hit():
	print("Hit player!")

func _on_hitbox_enter(area):
	var game_object = area.get_parent()
	if game_object.is_in_group("Player"):
		_on_player_hit()
