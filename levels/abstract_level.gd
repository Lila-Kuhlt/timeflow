extends Node2D

@onready var tile_map : TileMapLayer = $PlaceableTileMap
@onready var ghost_map : TileMapLayer = $GhostTileMap
var hovered_tile_before
var chosen_atlas_sourceid #represents the ID of the atlas in your tileset (you can have many atlases in any given set, so it needs to know which one to grab). If you only have one atlas set up, this will be 0
var chosen_atlas_coord #specific tile to assign from within that tileset source

# selected == mouse hover
func get_selected_tile() -> Vector2i:
	var mouse_pos = get_viewport().get_mouse_position()
	var map_coord = tile_map.local_to_map(to_local(mouse_pos))
	return map_coord
	
func _process(delta: float):
	var hovered_tile = get_selected_tile()
	if hovered_tile != hovered_tile_before:
		ghost_map.set_cell(hovered_tile_before, -1, Vector2i(-1, -1), -1)  # removes cell
		ghost_map.set_cell(hovered_tile, chosen_atlas_sourceid, chosen_atlas_coord)
		hovered_tile_before = hovered_tile
		
