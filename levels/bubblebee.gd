extends Node2D

var speed = 100
var direction = Vector2.ZERO
var screen_size
var elapsedTime = 0

func _ready():
	direction = Vector2i(randi_range(-1,1), randi_range(-1,1))
	speed = randf_range(50, 200)
	screen_size = get_parent().to_local(get_viewport().size)
	#var coords_vp = get_parent().to_local(get_viewport().size)
	#position = Vector2(randf_range(scale.x, coords_vp.x - scale.x), randf_range(scale.y, coords_vp.y - scale.y))

func _process(delta):
	position -= direction * speed * delta
	var local_pos = to_local(position)
	elapsedTime += delta
	if(elapsedTime > 0.1):
		direction = Vector2(direction.x + randf_range(-0.5, 0.5), direction.y + randf_range(-0.5, 0.5)).normalized()
		elapsedTime = 0

func _change_speed_leaving_area(area: Area2D):
	speed = -speed
	direction = Vector2(direction.x + randf_range(0, 1), direction.y + randf_range(0, 1)).normalized()
