extends Node2D
class_name Level

const Tile = Shared.Tile
const Rotation = Shared.Rotation
const State = Shared.State

@onready var tile_map : TileMapLayer = $PlaceableTileMap
@onready var ghost_map : TileMapLayer = $GhostTileMap
@onready var tile_selector : TileSelectorMenu = $TileSelectorMenu
var hovered_tile_before
var chosen_atlas_coord #specific tile to assign from within that tileset source
# maps tile ids to its available count
@export var available_tiles: Dictionary[Shared.Tile, int] = {
	Shared.Tile.STRAIGHT: 5,
	Shared.Tile.CROSS: 5,
	Shared.Tile.CURVE: 5,
	Shared.Tile.T: 5,
}

func _ready() -> void:
	tile_selector.init_tiles(available_tiles)

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
		# ghost_map.set_cell(hovered_tile, tile_selector.selected_tile, chosen_atlas_coord)
		# hovered_tile_before = hovered_tile
		place_tile_on_coordinate(Vector2i(0, 0), Tile.STRAIGHT, Rotation.UP)

func place_tile_on_coordinate(coords: Vector2i, type: Tile, rotation: Rotation) -> void:
	var tile_coordinates: Vector2i = get_tile_atlas_coords_from_enums(type, rotation)
	tile_map.set_cell(coords, 0, tile_coordinates)
	
# Return type: {"tile": <Tile type>, "rotation": <Rotation type>}
func get_enum_from_atlas_coords(coords: Vector2i):
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
		
	
func get_tile_atlas_coords_from_enums(type: Tile, rotation: Rotation):
	match type:
		Tile.STRAIGHT:
			match rotation:
				Rotation.UP, Rotation.DOWN:
					return Vector2i(0, 2)
				Rotation.LEFT, Rotation.RIGHT:
					return Vector2i(2, 1)
		Tile.CROSS:
			match rotation:
				_:
					return Vector2i(1, 1)
		Tile.CURVE:
			match rotation:
				Rotation.UP:
					return Vector2i(2, 0)
				Rotation.LEFT:
					return Vector2i(0, 0)
				Rotation.DOWN:
					return Vector2i(1, 0)
				Rotation.RIGHT:
					return Vector2i(0, 1)
		Tile.T:
			match rotation:
				Rotation.UP:
					return Vector2i(1, 3)
				Rotation.LEFT:
					return Vector2i(2, 2)
				Rotation.DOWN:
					return Vector2i(1, 2)
				Rotation.RIGHT:
					return Vector2i(0, 3)

	return null
