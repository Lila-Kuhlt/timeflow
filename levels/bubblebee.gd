extends CanvasLayer

var speed := 200.0
const margin := 0.15
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var bee_node: Node2D = $BeeNode

func _ready():
	update_next_path()

func rand_position() -> Vector2:
	return Vector2(
		randf_range(margin, 1.0 - margin),
		randf_range(margin, 1.0 - margin),
	) * get_viewport().get_visible_rect().size

func update_next_path():
	print('update next path')
	var oldpos := path.curve.get_point_position(1)
	var oldin := path.curve.get_point_in(1)
	path.curve.set_point_position(0, oldpos)
	path.curve.set_point_out(0, -oldin)
	var newpos := rand_position()
	var newin := rand_position() - newpos # newin is relative to newpos
	print('newin ', newin)
	print('newpos ', newpos)
	path.curve.set_point_in(1, newin)
	path.curve.set_point_position(1, newpos)

func _process(delta):
	path_follow.progress += delta * speed
	bee_node.global_position = path_follow.position
	if path_follow.progress_ratio >= 1.0:
		update_next_path()
		path_follow.progress_ratio = 0.0
