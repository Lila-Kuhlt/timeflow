extends Node2D

var speed = 100
var direction = Vector2.ZERO
var screen_size
var elapsedTime = 0
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var bee_node: Node2D = $BeeNode

func _ready():
	direction = Vector2i(randi_range(-1,1), randi_range(-1,1))
	speed = randf_range(50, 200)
	screen_size = get_parent().to_local(get_viewport().size)
	#var coords_vp = get_parent().to_local(get_viewport().size)
	#position = Vector2(randf_range(scale.x, coords_vp.x - scale.x), randf_range(scale.y, coords_vp.y - scale.y))
	update_next_path()

func rand_position() -> Vector2:
	var viewport := get_viewport_rect()
	var vw_start: Vector2 = get_parent().to_local(viewport.position)
	var vw_end: Vector2 = get_parent().to_local(viewport.end)
	print(viewport)
	return Vector2(
		randf_range(vw_start.x, vw_end.x),
		randf_range(vw_start.y, vw_end.y),
	)

func update_next_path():
	print('update next path')
	var oldpos := path.curve.get_point_position(1)
	var oldin := path.curve.get_point_in(1)
	path.curve.set_point_position(0, oldpos)
	path.curve.set_point_out(0, oldin)
	var newin := rand_position()
	var newpos := rand_position()
	print('newin ', newin)
	print('newpos ', newpos)
	path.curve.set_point_in(1, newin)
	path.curve.set_point_position(1, newpos)

func _process(delta):
	path_follow.progress += delta * 500.0
	bee_node.global_position = path_follow.position
	print('prog ', path_follow.progress_ratio)
	print('pos ', path_follow.position)
	if path_follow.progress_ratio >= 1.0:
		update_next_path()
		path_follow.progress_ratio = 0.0
	# position -= direction * speed * delta
	# var local_pos = to_local(position)
	# elapsedTime += delta
	# if(elapsedTime > 0.1):
	# 	direction = Vector2(direction.x + randf_range(-0.5, 0.5), direction.y + randf_range(-0.5, 0.5)).normalized()
	# 	elapsedTime = 0

# func _change_speed_leaving_area(area: Area2D):
# 	speed = -speed
# 	direction = Vector2(direction.x + randf_range(0, 1), direction.y + randf_range(0, 1)).normalized()
