extends Node2D

class_name player

@export var speed : float = 500;
@export var focused_speed : float = 200;
@onready var cd_throw : = $Timer
@onready var rebound_area := $Rebound #é importante que a layer e a mask disso daqui são diferentes da do player, e dos inimigos, e igual a da throwable bullet
var has_bullet : bool = false
var parried_bullet
var throwed_bullet_instance = load("res://resources/Throwed_bullet.tscn")
var throwed_bullet_spawn
var input_dir : Vector2

func _process(delta):
	input_dir = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	var speed_multiplier = focused_speed if Input.is_action_pressed("focus_movement") else speed
	if has_bullet:
		speed_multiplier = 0
	var next_pos = position + input_dir.normalized() * speed_multiplier * delta
	position = next_pos
	if Input.is_action_just_pressed("throwback") && cd_throw.is_stopped() : parry()
	if Input.is_action_just_released("throwback") && has_bullet : throw(parried_bullet)
		
func _on_bullet_hit():
	position = Vector2.ZERO
	print("die")
	
func parry():
#	cd_throw.start()
	var overlapping_areas = rebound_area.get_overlapping_areas()
	if overlapping_areas:
		print(overlapping_areas)
		for area in overlapping_areas:
			if area.is_in_group("Throwable_bullet"):
				parried_bullet = area.get_parent().deactivate()
		has_bullet = true
		
func throw(bullet):
	#position: Vector2, direction:Vector2, shape:= Globals.BulletShape.circle, color := "red", color_is_negative := false
	throwed_bullet_spawn = throwed_bullet_instance.instantiate()
	throwed_bullet_spawn.get_node("Area2D/CollisionShape2D").shape = throwed_bullet_spawn.BulletData[bullet.instanced_shape]["shape"]
	throwed_bullet_spawn.position = self.position
	throwed_bullet_spawn.direction = self.input_dir.normalized()
	throwed_bullet_spawn.look_at(self.position + throwed_bullet_spawn.direction)
	throwed_bullet_spawn.animation = bullet.animation
	throwed_bullet_spawn.material.set("shader_paramater/hue_shift", throwed_bullet_spawn.ColorShift[bullet.instanced_color])
	throwed_bullet_spawn.material.set("shader_parameter/sat_mul", 2)
	throwed_bullet_spawn.material.set("shader_parameter/val_mul", 0.5)
	throwed_bullet_spawn.material.set("shader_parameter/is_negative", true)
	bullet.get_parent().add_child(throwed_bullet_spawn)
#	self.position = position
#	self.direction = direction.normalized()
#	self.look_at(position+self.direction)
#	self.visible = true
#	self.process_mode = Node.PROCESS_MODE_INHERIT
#	self.travelled_distance = 0.0
#	self.time_alive = 0.0
#	self.animation = BulletData[shape]["animation"]
#	self.material.set("shader_parameter/hue_shift", ColorShift[color])
#	if color_is_negative:
#		rebound_box.shape = BulletData[shape]["shape"]
#		self.material.set("shader_parameter/is_negative", true)
#	query.shape = BulletData[shape]["shape"]
	has_bullet = false
	pass
