extends Node2D

const Shared = preload("shared.gd")
const Tile = Shared.Tile
const Rotation = Shared.Rotation
const State = Shared.State

@onready var tile_map : TileMapLayer = $PlaceableTileMap
@onready var ghost_map : TileMapLayer = $GhostTileMap
@onready var tile_selector : TileSelectorMenu = $TileSelectorMenu
var hovered_tile_before
var chosen_atlas_coord #specific tile to assign from within that tileset source
# maps tile ids to its available count
@export var available_tiles := {
	Shared.Tile.STRAIGHT: 5,
	Shared.Tile.CROSS: 5,
	Shared.Tile.CURVE: 5,
	Shared.Tile.T: 5,
}

# selected == mouse hover
func get_selected_tile() -> Vector2i:
	var mouse_pos = get_viewport().get_mouse_position()
	var map_coord = tile_map.local_to_map(to_local(mouse_pos))
	return map_coord

func _process(_delta: float):
	var hovered_tile = get_selected_tile()
	if hovered_tile != hovered_tile_before:
		if hovered_tile_before != null:
			ghost_map.set_cell(hovered_tile_before, -1, Vector2i(-1, -1), -1)  # removes cell
		ghost_map.set_cell(hovered_tile, tile_selector.selected_tile, chosen_atlas_coord)
		hovered_tile_before = hovered_tile
		place_tile_on_coordinate(Vector2i(0, 0), Shared.Tile.STRAIGHT, Shared.Rotation.UP, Shared.State.EMPTY)

func place_tile_on_coordinate(coords: Vector2i, type: Shared.Tile, rotation: Shared.Rotation, state: Shared.State):
	var tile_coordinates: Vector2i = get_tile_atlas_coords_from_enums(type, rotation)
	tile_map.set_cell(coords, state, tile_coordinates)
	
func get_tile_atlas_coords_from_enums(type: Shared.Tile, rotation: Shared.Rotation) -> Vector2i:
	match type:
		Shared.Tile.STRAIGHT:
			match rotation:
				Shared.Rotation.UP, Shared.Rotation.DOWN:
					return Vector2i(0, 2)
				Shared.Rotation.LEFT, Shared.Rotation.RIGHT:
					return Vector2i(2, 1)
		Shared.Tile.CROSS:
			match rotation:
				_:
					return Vector2i(1, 1)
		Shared.Tile.CURVE:
			match rotation:
				Shared.Rotation.UP:
					return Vector2i(2, 0)
				Shared.Rotation.LEFT:
					return Vector2i(0, 1)
				Shared.Rotation.DOWN:
					return Vector2i(1, 0)
				Shared.Rotation.RIGHT:
					return Vector2i(0, 0)
		Shared.Tile.T:
			match rotation:
				Shared.Rotation.UP:
					return Vector2i(1, 3)
				Shared.Rotation.LEFT:
					return Vector2i(0, 3)
				Shared.Rotation.DOWN:
					return Vector2i(1, 2)
				Shared.Rotation.RIGHT:
					return Vector2i(2, 2)
					
	return Vector2i(0, 0)
