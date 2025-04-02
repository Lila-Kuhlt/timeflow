extends Node2D

const Shared = preload("shared.gd")

@onready var tile_map : TileMapLayer = $PlaceableTileMap
@onready var ghost_map : TileMapLayer = $GhostTileMap
@onready var tile_selector : TileSelectorMenu = $TileSelectorMenu
var hovered_tile_before
var chosen_atlas_coord #specific tile to assign from within that tileset source
# maps tile ids to its available count
@export var available_tiles := {
	Tile.STRAIGHT: 5,
	Tile.CROSS: 5,
	Tile.CURVE: 5,
	Tile.T: 5,
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
		place_tile_on_coordinate(Vector2i(0, 0), Shared.Tile.STRAIGHT, Shared.Rotation.UP)

func place_tile_on_coordinate(coords: Vector2i, type: Shared.Tile, rotation: Shared.Rotation):
	var test := Vector2i(1, 1)
	tile_map.set_cell(coords, 0, test)
