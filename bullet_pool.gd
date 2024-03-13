extends Node

class_name BulletPool
var _bullet_scene = preload("res://game_objects_scenes/Bullet.tscn")

var _pool_size = 4096
var _pool = []
var _index = 0

func _ready():
	preload_objects()
	
func preload_objects():
	for i in range(_pool_size):
		var bullet : Bullet = _bullet_scene.instantiate()
		bullet.deactivate()
		_pool.append(bullet)
		self.add_child(bullet)

func get_object():
	var obj = _pool[_index]
	_index = (_index + 1) % _pool_size
	return obj
