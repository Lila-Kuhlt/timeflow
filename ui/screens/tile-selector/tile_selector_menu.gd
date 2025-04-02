extends CanvasLayer
class_name TileSelectorMenu

signal tile_select_changed(idx: int)

var tile_count := 3
var tiles: Array[TileSelectorTile] = []
var selected_tile := -1

func _ready():
	var tile_container = $MarginContainer/Panel/HBoxContainer
	for i in range(tile_count):
		var tilename := "TileSelectorTile%d" % (i+1)
		var tile: TileSelectorTile = tile_container.get_node(tilename)
		tile.idx = i
		tile.connect("on_clicked", on_select_tile)
		tiles.append(tile)
	on_select_tile(tiles[0])

func on_select_tile(tile: TileSelectorTile):
	if selected_tile == tile.idx:
		return
	tiles[selected_tile].on_deselect()
	tile.on_select()
	selected_tile = tile.idx
	tile_select_changed.emit(selected_tile)
