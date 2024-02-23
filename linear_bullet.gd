extends Bullet
class_name LinearBullet

var _travelled_distance := 0

func _ready():
	direction = direction.normalized()


func _process(delta):
	var next_step = direction * speed * delta
	position += next_step
	_travelled_distance += next_step.length()
	rotation += delta

	if _travelled_distance > max_distance:
		queue_free()
