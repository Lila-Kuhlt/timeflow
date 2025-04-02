extends CanvasLayer
class_name TileSelectorMenu

signal tile_select_changed(idx: int)

@onready var tile_container = $MarginContainer/Panel/HBoxContainer
var tiles: Array[TileSelectorTile] = []
var selected_tile := -1
var selected_tile_idx := -1

func init_tiles(t: Dictionary[int, int]):
	for i in range(3):
		var tilename := "TileSelectorTile%d" % (i+1)
		var tile: TileSelectorTile = tile_container.get_node(tilename)
		tile.idx = i
		tile.connect("on_clicked", on_select_tile)
		tiles.append(tile)
	on_select_tile(tiles[0])


func on_select_tile(tile: TileSelectorTile):
	if selected_tile_idx == tile.idx:
		return
	tiles[selected_tile_idx].on_deselect()
	tile.on_select()
	selected_tile_idx = tile.idx
	tile_select_changed.emit(selected_tile_idx)
