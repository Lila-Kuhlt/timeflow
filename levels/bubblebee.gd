extends CanvasLayer

var speed := 200.0
const margin := 0.15
var is_aimless := true
var outphase := false
var target_reached := false
var target_coords: Vector2
var target_type: Shared.Tile
@onready var level: Level = $".."
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var bee_node: Node2D = $BeeNode
@onready var aimless_timer: Timer = $AimlessTimer
@onready var occupy_timer: Timer = $OccupyTimer

signal on_blocking_toggle(tile: Shared.Tile, block: bool)

func _ready():
	update_target(rand_position())
	aimless_timer.start()

func on_leave_aimless_mode() -> void:
	aimless_timer.stop()
	var tiles := level.tile_selector.tiles
	var tile_idx := randi_range(0, len(tiles) - 1)
	var tile_btn := tiles[tile_idx]
	target_coords = tile_btn.global_position + tile_btn.size * 0.5
	target_type = tile_btn.tile_type
	target_reached = false
	outphase = false
	is_aimless = false

func on_leave_occupy_mode() -> void:
	occupy_timer.stop()
	on_blocking_toggle.emit(target_type, false)
	is_aimless = true
	aimless_timer.start()

func rand_position() -> Vector2:
	return Vector2(
		randf_range(margin, 1.0 - margin),
		randf_range(margin, 1.0 - margin),
	) * get_viewport().get_visible_rect().size

func update_target(newpos: Vector2):
	var oldpos := path.curve.get_point_position(1)
	var oldin := path.curve.get_point_in(1)
	path.curve.set_point_position(0, oldpos)
	path.curve.set_point_out(0, -oldin)
	var newin := rand_position() - newpos # newin is relative to newpos
	path.curve.set_point_in(1, newin)
	path.curve.set_point_position(1, newpos)

func _process(delta):
	if is_aimless or not target_reached:
		path_follow.progress += delta * speed
		bee_node.global_position = path_follow.position
		if path_follow.progress_ratio >= 1.0:
			if is_aimless:
				update_target(rand_position())
				path_follow.progress_ratio = 0.0
			elif not outphase:
				update_target(target_coords)
				path_follow.progress_ratio = 0.0
				outphase = true
			else:
				target_reached = true
				on_blocking_toggle.emit(target_type, true)
				occupy_timer.start()
				path_follow.progress_ratio = 1.0
