extends CanvasLayer
class_name TileSelectorMenu

signal tile_select_changed(idx: int)

const TileSelectorTileScene := preload("res://ui/components/TileSelectorTile.tscn")
@onready var tile_container = $MarginContainer/Panel/HBoxContainer
var tiles: Array[TileSelectorTile] = []
var selected_tile: Shared.Tile = -1
var selected_tile_idx := -1

func init_tiles(t: Dictionary[Shared.Tile, int]):
	var i := 0
	for tile_ty: Shared.Tile in t:
		var tilename := "TileSelectorTile%d" % (i+1)
		var tile: TileSelectorTile = TileSelectorTileScene.instantiate()
		tile.idx = i
		tile.connect("on_clicked", on_select_tile)
		tiles.append(tile)
		tile_container.add_child(tile)
		tile.set_tile_type(tile_ty)
		i += 1
	on_select_tile(tiles[0])


func on_select_tile(tile: TileSelectorTile):
	if selected_tile_idx == tile.idx:
		return
	tiles[selected_tile_idx].on_deselect()
	tile.on_select()
	selected_tile_idx = tile.idx
	selected_tile = tile.tile_type
	tile_select_changed.emit(selected_tile_idx)
