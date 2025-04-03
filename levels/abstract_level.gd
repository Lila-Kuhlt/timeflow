extends Node2D
class_name Level

const Tile = Shared.Tile
const Rotation = Shared.Rotation
const State = Shared.State

@onready var tile_map: TileMapLayer = $PlaceableTileMap
@onready var checkpoint_map: TileMapLayer = $CheckpointTileMap
@onready var ghost_map: TileMapLayer = $GhostTileMap
@onready var water_map: TileMapLayer = $WaterTileMap
@onready var tile_selector: TileSelectorMenu = $TileSelectorMenu
var hovered_tile_before: Vector2i
var chosen_atlas_coord: Vector2i #specific tile to assign from within that tileset source
var chosen_rot: Rotation = Rotation.UP
# maps tile ids to its available count
@export var available_tiles: Dictionary[Shared.Tile, int] = {
	Shared.Tile.STRAIGHT: 5,
	Shared.Tile.CROSS: 5,
	Shared.Tile.CURVE: 5,
	Shared.Tile.T: 5,
}
var water_heads: Array[Vector2i] = []

signal loss()

func _ready() -> void:
	tile_selector.init_tiles(available_tiles)

# selected == mouse hover
func get_selected_tile() -> Vector2i:
	var mouse_pos = get_viewport().get_mouse_position()
	var map_coord = tile_map.local_to_map(to_local(mouse_pos))
	return map_coord

func update_hovered_tile(hovered_tile):
	ghost_map.set_cell(hovered_tile_before)  # removes cell
	chosen_atlas_coord = get_tile_atlas_coords_from_enums(tile_selector.selected_tile, chosen_rot)
	ghost_map.set_cell(hovered_tile, 0, chosen_atlas_coord)
	hovered_tile_before = hovered_tile

func _process(_delta: float):
	var hovered_tile = get_selected_tile()
	if hovered_tile != hovered_tile_before:
		update_hovered_tile(hovered_tile)
	if Input.is_action_just_pressed('place_tile'):
		place_tile_on_coordinate(hovered_tile, tile_selector.selected_tile, chosen_rot)
	if Input.is_action_just_pressed('rotate_left'):
		chosen_rot = Shared.rotate_left(chosen_rot)
		update_hovered_tile(hovered_tile)
	if Input.is_action_just_pressed('rotate_right'):
		chosen_rot = Shared.rotate_right(chosen_rot)
		update_hovered_tile(hovered_tile)
	if Input.is_action_just_pressed('remove_tile'):
		remove_tile_on_coordinate(hovered_tile)

func place_tile_on_coordinate(coords: Vector2i, type: Tile, orientation: Rotation) -> void:
	var tile_coordinates: Vector2i = get_tile_atlas_coords_from_enums(type, orientation)
	tile_map.set_cell(coords, 0, tile_coordinates)

func remove_tile_on_coordinate(coords: Vector2i):
	tile_map.set_cell(coords)

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

	return null

func get_directions(type: Tile, orientation: Rotation) -> Array[Rotation]:
	match type:
		Tile.STRAIGHT:
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
		Rotation.UP: return coords + Vector2i(-1, 0)
		Rotation.LEFT: return coords + Vector2i(0, -1)
		Rotation.DOWN: return coords + Vector2i(1, 0)
		Rotation.RIGHT: return coords + Vector2i(0, 1)
		_: return coords

func flow_tick():
	var old_water_heads = water_heads.duplicate()
	for head in old_water_heads:
		var head_coords := tile_map.get_cell_atlas_coords(head)
		var head_data: Dictionary = get_enum_from_atlas_coords(head_coords)
		for direction in get_directions(head_data["tile"], head_data["rotation"]):
			var neighbor = move_in_direction(direction, head)
			var neighbor_coords := tile_map.get_cell_atlas_coords(neighbor)
			var neighbor_data: Dictionary = get_enum_from_atlas_coords(neighbor_coords)
			# TODO: check if neighbor has water
			if Shared.reflect(direction) in get_directions(neighbor_data["tile"], neighbor_data["rotation"]):
				pass # TODO: fill with water, add to water_heads
			else:
				loss.emit()
