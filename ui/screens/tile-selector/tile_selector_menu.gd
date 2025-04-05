extends CanvasLayer
class_name TileSelectorMenu

signal tile_select_changed(idx: int)

const TileSelectorTileScene := preload("res://ui/components/TileSelectorTile.tscn")
@onready var tile_container = $MarginContainer/Panel/MarginContainer/HBoxContainer
@onready var fast_forward_button: TextureButton = $MarginContainer/Panel/Panel/FastForwardButton
var tiles: Array[TileSelectorTile] = []
var type_to_index: Dictionary[Shared.Tile, int] = {}
var selected_tile: Shared.Tile = -1
var selected_tile_idx := -1
@onready var flower_count_label: Label = $MarginContainer2/FlowerPanel/FlowerCount

func init_tiles(t: Dictionary[Shared.Tile, int]):
	var i := 0
	for tile_ty: Shared.Tile in t:
		if t[tile_ty] == 0:
			continue
		var tilename := "TileSelectorTile%d" % (i+1)
		var tile: TileSelectorTile = TileSelectorTileScene.instantiate()
		tile.idx = i
		tile.connect("on_clicked", on_select_tile)
		tiles.append(tile)
		type_to_index[tile_ty] = i
		tile_container.add_child(tile)
		tile.set_tile_type(tile_ty)
		tile.set_tile_count(t[tile_ty])
		i += 1
	on_select_tile(tiles[0])

func update_tile_count(ty: Shared.Tile, count: int):
	var tile: TileSelectorTile = tiles[type_to_index[ty]]
	tile.set_tile_count(count)

func update_flower_count(flower_count):
	flower_count_label.text = str(flower_count)#

func on_select_tile(tile: TileSelectorTile):
	if selected_tile_idx == tile.idx:
		return
	tiles[selected_tile_idx].on_deselect()
	tile.on_select()
	selected_tile_idx = tile.idx
	selected_tile = tile.tile_type
	tile_select_changed.emit(selected_tile_idx)
