extends Node2D
class_name Level

const Tile = Shared.Tile
const Rotation = Shared.Rotation
const State = Shared.State

@onready var rotateSFXAudio : AudioStreamPlayer = $AudioRotationSound
@onready var placeSFXAudio : AudioStreamPlayer = $AudioPlacementSound
@onready var removeSFXAudio : AudioStreamPlayer = $AudioRemoveSound
@onready var bg_map: TileMapLayer = $BackgroundTileMap
@onready var tile_map: TileMapLayer = $PlaceableTileMap
@onready var ghost_map: TileMapLayer = $GhostTileMap
@onready var water_map: TileMapLayer = $WaterTileMap
@onready var checkpoint_map: TileMapLayer = $CheckpointTileMap
@onready var tile_selector: TileSelectorMenu = $TileSelectorMenu
@onready var fluid_timer: Timer = $FluidTimer
@onready var decorative_map: TileMapLayer = $DecorativeTileMap

var current_checkpoint_index: int = 0 # Index of next checkpoint to reach

var bumblebee_blockers: Array[Tile] = []
var blocker_source_id: int
var is_in_panic := false
var hovered_tile: Vector2i
var chosen_atlas_coord: Vector2i # specific tile to assign from within that tileset source
var chosen_rot: Rotation = Rotation.UP
var flower_source_ids: Array[int] = []
# Maps tile ids to its available count.
# -1 means infinity
@export var available_tiles: Dictionary[Shared.Tile, int] = {
	Shared.Tile.STRAIGHT: 5,
	Shared.Tile.CROSS: 5,
	Shared.Tile.CURVE: -1,
	Shared.Tile.T: 5,
	Shared.Tile.DELAY: 5,
}

# Array of arrays of Vector2i
@export var checkpoint_groups: Array[Array] = [[]]

var water_heads: Array[Vector2i] = []
var delay_map: Dictionary[Vector2i, int] = {}

signal loss()
signal win()

func _ready() -> void:
	tile_selector.init_tiles(available_tiles)
	tile_selector.fast_forward_button.connect("toggled", on_fast_forward_toggle)

	for i in range(ghost_map.tile_set.get_source_count()):
		var id := ghost_map.tile_set.get_source_id(i)
		var source := ghost_map.tile_set.get_source(id)
		if source.resource_name == 'Blocker':
			blocker_source_id = id
		elif source.resource_name.begins_with("flower_"):
			flower_source_ids.append(id)

	water_heads.append(Vector2i(0, 0))
	set_tile_water_state(Vector2i(0, 0), State.FULL)

	for i in range(checkpoint_groups.size()):
		for checkpoint in checkpoint_groups[i]:
			checkpoint_map.set_cell(checkpoint, 4, Vector2i(0, 0), 1)

func on_fast_forward_toggle(enable: bool) -> void:
	if enable:
		fluid_timer.wait_time = 0.3
		if fluid_timer.time_left > fluid_timer.wait_time:
			fluid_timer.start()
	else:
		fluid_timer.wait_time = 1.25

func update_fast_forward_button(enable: bool) -> void:
	tile_selector.fast_forward_button.button_pressed = enable

# selected == mouse hover
func get_selected_tile() -> Vector2i:
	var mouse_pos = $Camera2D.get_local_mouse_position()
	var map_coord = tile_map.local_to_map(mouse_pos)
	return map_coord

func update_hovered_tile(new_hovered_tile):
	ghost_map.set_cell(hovered_tile)  # removes cell
	hovered_tile = new_hovered_tile
	if not is_floor_placeable(new_hovered_tile):
		return
	if tile_selector.selected_tile in bumblebee_blockers:
		ghost_map.set_cell(new_hovered_tile, blocker_source_id, Vector2i(0, 0))
	else:
		chosen_atlas_coord = get_tile_atlas_coords_from_enums(tile_selector.selected_tile, chosen_rot)
		ghost_map.set_cell(new_hovered_tile, 0, chosen_atlas_coord)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('place_tile'):
		if get_tile_water_state(hovered_tile) == State.EMPTY and is_floor_placeable(hovered_tile) and tile_selector.selected_tile not in bumblebee_blockers:
			var is_ok := (available_tiles[tile_selector.selected_tile] != 0)
			if not is_ok:
				var atlas_coord := tile_map.get_cell_atlas_coords(hovered_tile)
				if atlas_coord != Vector2i(-1, -1):
					var tile_info = get_enum_from_atlas_coords(atlas_coord)
					is_ok = tile_info['tile'] == tile_selector.selected_tile
			if is_ok:
				remove_tile_on_coordinate(hovered_tile)
				place_tile_on_coordinate(hovered_tile, tile_selector.selected_tile, chosen_rot)
		elif decorative_map.get_cell_source_id(hovered_tile) in flower_source_ids:
			decorative_map.set_cell(hovered_tile)
	if event.is_action_pressed('rotate_left'):
		chosen_rot = Shared.rotate_left(chosen_rot)
		update_hovered_tile(hovered_tile)
		rotateSFXAudio.play(0.1)
	if event.is_action_pressed('rotate_right'):
		chosen_rot = Shared.rotate_right(chosen_rot)
		update_hovered_tile(hovered_tile)
		rotateSFXAudio.play(0.1)
	if event.is_action_pressed('remove_tile') and get_tile_water_state(hovered_tile) == State.EMPTY:
		remove_tile_on_coordinate(hovered_tile)
	for i in range(len(tile_selector.tiles)):
		if event is InputEventKey and event.pressed and event.physical_keycode == KEY_1 + i:
			tile_selector.on_select_tile(tile_selector.tiles[i])
			update_hovered_tile(hovered_tile)
			break
	if event.is_action_pressed("fast_forward"):
		on_fast_forward_toggle(true)
		update_fast_forward_button(true)
	elif event.is_action_released("fast_forward"):
		on_fast_forward_toggle(false)
		update_fast_forward_button(false)

func _process(_delta: float):
	var new_hovered_tile = get_selected_tile()
	if new_hovered_tile != hovered_tile:
		update_hovered_tile(new_hovered_tile)

func is_tile_available() -> bool:
	return available_tiles[tile_selector.selected_tile] != 0

func is_floor_placeable(coords: Vector2i) -> bool:
	var source_id := bg_map.get_cell_source_id(coords)
	return source_id == 1  # check for grass tile

func update_tile_count(tile: Tile):
	tile_selector.update_tile_count(tile, available_tiles[tile])

func on_bumblebee_blocker_toggle(tile: Tile, block: bool):
	if block:
		bumblebee_blockers.append(tile)
	else:
		bumblebee_blockers.erase(tile)
	update_hovered_tile(get_selected_tile())

func place_tile_on_coordinate(coords: Vector2i, type: Tile, orientation: Rotation) -> void:
	var tile_coordinates: Vector2i = get_tile_atlas_coords_from_enums(type, orientation)
	tile_map.set_cell(coords, 0, tile_coordinates)
	placeSFXAudio.play(0)
	if available_tiles[type] > 0:
		available_tiles[type] -= 1
		update_tile_count(type)

func remove_tile_on_coordinate(coords: Vector2i):
	var atlas_coords := tile_map.get_cell_atlas_coords(coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	var tile_info: Dictionary = get_enum_from_atlas_coords(atlas_coords)
	var tile: Tile = tile_info['tile']
	if available_tiles[tile] >= 0:
		available_tiles[tile] += 1
		update_tile_count(tile)
	tile_map.set_cell(coords)
	removeSFXAudio.play(0)

func set_tile_water_state(coords: Vector2i, state: State):
	if state == State.EMPTY:
		water_map.set_cell(coords, -1, Vector2i(-1, -1), -1)
		return
	var atlas_coords := tile_map.get_cell_atlas_coords(coords)
	water_map.set_cell(coords, 0, atlas_coords)

func get_tile_water_state(coords: Vector2i) -> State:
	return State.FULL if water_map.get_cell_source_id(coords) == 0 else State.EMPTY

# Return type: {"tile": <Tile type>, "rotation": <Rotation type>}
static func get_enum_from_atlas_coords(coords: Vector2i):
	match coords.x:
		0:
			match coords.y:
				0:
					return {"tile": Tile.CURVE, "rotation": Rotation.LEFT}
				1:
					return {"tile": Tile.CURVE, "rotation": Rotation.RIGHT}
				2:
					return {"tile": Tile.STRAIGHT, "rotation": Rotation.UP}
				3:
					return {"tile": Tile.T, "rotation": Rotation.RIGHT}
				4:
					return {"tile": Tile.DELAY, "rotation": Rotation.UP}
		1:
			match coords.y:
				0:
					return {"tile": Tile.CURVE, "rotation": Rotation.DOWN}
				1:
					return {"tile": Tile.CROSS, "rotation": Rotation.UP}
				2:
					return {"tile": Tile.T, "rotation": Rotation.DOWN}
				3:
					return {"tile": Tile.T, "rotation": Rotation.UP}
		2:
			match coords.y:
				0:
					return {"tile": Tile.CURVE, "rotation": Rotation.UP}
				1:
					return {"tile": Tile.STRAIGHT, "rotation": Rotation.LEFT}
				2:
					return {"tile": Tile.T, "rotation": Rotation.LEFT}
				3:
					return {"tile": Tile.DELAY, "rotation": Rotation.LEFT}

	return null

static func get_tile_atlas_coords_from_enums(type: Tile, orientation: Rotation):
	match type:
		Tile.STRAIGHT:
			match orientation:
				Rotation.UP, Rotation.DOWN:
					return Vector2i(0, 2)
				Rotation.LEFT, Rotation.RIGHT:
					return Vector2i(2, 1)
		Tile.CROSS:
			match orientation:
				_:
					return Vector2i(1, 1)
		Tile.CURVE:
			match orientation:
				Rotation.UP:
					return Vector2i(2, 0)
				Rotation.LEFT:
					return Vector2i(0, 0)
				Rotation.DOWN:
					return Vector2i(1, 0)
				Rotation.RIGHT:
					return Vector2i(0, 1)
		Tile.T:
			match orientation:
				Rotation.UP:
					return Vector2i(1, 3)
				Rotation.LEFT:
					return Vector2i(2, 2)
				Rotation.DOWN:
					return Vector2i(1, 2)
				Rotation.RIGHT:
					return Vector2i(0, 3)
		Tile.DELAY:
			match orientation:
				Rotation.UP, Rotation.DOWN:
					return Vector2i(0, 4)
				Rotation.LEFT, Rotation.RIGHT:
					return Vector2i(2, 3)

	return null

func get_directions(type: Tile, orientation: Rotation) -> Array[Rotation]:
	match type:
		Tile.STRAIGHT, Tile.DELAY:
			match orientation:
				Rotation.UP, Rotation.DOWN:
					return [Rotation.UP, Rotation.DOWN]
				Rotation.LEFT, Rotation.RIGHT:
					return [Rotation.LEFT, Rotation.RIGHT]
		Tile.CROSS:
			match orientation:
				_:
					return [Rotation.UP, Rotation.LEFT, Rotation.DOWN, Rotation.RIGHT]
		Tile.CURVE:
			match orientation:
				Rotation.UP:
					return [Rotation.UP, Rotation.LEFT]
				Rotation.LEFT:
					return [Rotation.LEFT, Rotation.DOWN]
				Rotation.DOWN:
					return [Rotation.DOWN, Rotation.RIGHT]
				Rotation.RIGHT:
					return [Rotation.RIGHT, Rotation.UP]
		Tile.T:
			match orientation:
				Rotation.UP:
					return [Rotation.RIGHT, Rotation.UP, Rotation.LEFT]
				Rotation.LEFT:
					return [Rotation.UP, Rotation.LEFT, Rotation.DOWN]
				Rotation.DOWN:
					return [Rotation.LEFT, Rotation.DOWN, Rotation.RIGHT]
				Rotation.RIGHT:
					return [Rotation.DOWN, Rotation.RIGHT, Rotation.UP]
	return []

func move_in_direction(direction: Rotation, coords: Vector2i) -> Vector2i:
	match direction:
		Rotation.UP: return coords + Vector2i(0, -1)
		Rotation.LEFT: return coords + Vector2i(-1, 0)
		Rotation.DOWN: return coords + Vector2i(0, 1)
		Rotation.RIGHT: return coords + Vector2i(1, 0)
		_: return coords

func tick_delay(tile: Tile, coords: Vector2i) -> bool:
	if tile != Tile.DELAY:
		return true
	if coords not in delay_map:
		delay_map[coords] = 1
		return false
	delay_map[coords] -= 1
	if delay_map[coords] <= 0:
		delay_map.erase(coords)
		return true
	return false

func flow_single_head(head: Vector2, head_type: Tile, head_rot: Rotation, heads: Array[Vector2i], visited: Array[Vector2i] = []) -> bool:
	for direction in get_directions(head_type, head_rot):
		var neighbor = move_in_direction(direction, head)
		if neighbor == Vector2i(0, -1) or neighbor in visited:
			# TODO: real water soure/sink detection
			continue
		var neighbor_coords := tile_map.get_cell_atlas_coords(neighbor)
		var neighbor_data = get_enum_from_atlas_coords(neighbor_coords)
		if neighbor_data is Dictionary:
			var neighbor_directions = get_directions(neighbor_data["tile"], neighbor_data["rotation"])
			if Shared.reflect(direction) in neighbor_directions:
				if get_tile_water_state(neighbor) == State.FULL:
					continue
				visited.append(neighbor)
				heads.append(neighbor)
				continue
		return true
	return false

func flow_tick():
	var old_water_heads = water_heads.duplicate()
	water_heads.clear()
	for head in old_water_heads:
		var head_coords := tile_map.get_cell_atlas_coords(head)
		var head_data: Dictionary = get_enum_from_atlas_coords(head_coords)
		var head_type: Tile = head_data["tile"]
		if not tick_delay(head_type, head):
			water_heads.append(head)
			continue
		if flow_single_head(head, head_type, head_data["rotation"], water_heads):
			print("no way to flow")
			loss.emit()
			return
	for head in water_heads:
		set_tile_water_state(head, State.FULL)

	if water_heads.is_empty():
		# TODO add reason
		print("no water heads")
		loss.emit()
		return

	var any_on_checkpoint: bool = false
	var all_on_checkpoint: bool = true

	var checkpoints = checkpoint_groups[current_checkpoint_index]
	for head in water_heads:
		if head in checkpoints:
			any_on_checkpoint = true
		else:
			all_on_checkpoint = false

	var flow_depth := get_flow_depth()
	var should_panic := flow_depth < 5
	if should_panic and (not is_in_panic):
		is_in_panic = true
		Global.game_manager.main_theme_player.playing = false
		Global.game_manager.panic_theme_player.playing = true
	elif (not should_panic) and is_in_panic:
		is_in_panic = false
		Global.game_manager.main_theme_player.playing = true
		Global.game_manager.panic_theme_player.playing = false

	if all_on_checkpoint:
		print("checkpoint ", current_checkpoint_index, " complete")
		current_checkpoint_index += 1
		if current_checkpoint_index >= checkpoint_groups.size():
			win.emit()
	else:
		if any_on_checkpoint:
			# TODO add reason
			print("not all checkpoints reached at the same time: ", current_checkpoint_index)
			loss.emit()

func get_flow_depth() -> int:
	var heads := water_heads
	var visited: Array[Vector2i] = []
	var depth := 0
	while true:
		if heads.is_empty():
			return -1
		var new_heads: Array[Vector2i] = []
		var do_break := false
		for head in heads:
			if head in checkpoint_groups[current_checkpoint_index]:
				continue
			var head_coords := tile_map.get_cell_atlas_coords(head)
			var head_data: Dictionary = get_enum_from_atlas_coords(head_coords)
			var head_type: Tile = head_data["tile"]
			if flow_single_head(head, head_type, head_data["rotation"], new_heads, visited):
				do_break = true
				break
		if do_break: break
		heads = new_heads
		depth += 1
	return depth
