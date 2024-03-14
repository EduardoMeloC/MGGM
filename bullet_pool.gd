extends Node

class_name BulletPool
var _bullet_scene = preload("res://game_objects_scenes/Bullet.tscn")

var _pool_size = 4096
var _pool = []
var _index = 0

var _throwable_bullet = preload("res://resources/Throwable_bullet.tscn")
var _throwable_pool_size = 16
var _throwable_pool = []
var _throwable_index = 0

func _ready():
	preload_objects()
	
func preload_objects():
	for i in range(_pool_size):
		var bullet : Bullet = _bullet_scene.instantiate()
		bullet.deactivate()
		_pool.append(bullet)
		self.add_child(bullet)
	for j in range(_throwable_pool_size):
		var bullet : Bullet = _throwable_bullet.instantiate()
		bullet.deactivate()
		_throwable_pool.append(bullet)
		self.add_child(bullet)
		
func get_object(throwable : bool = false):
	if !throwable:
		var obj = _pool[_index]
		_index = (_index + 1) % _pool_size
		return obj
	else:
		var obj = _throwable_pool[_throwable_index]
		_throwable_index = (_throwable_index + 1) % _throwable_pool_size
		return obj
