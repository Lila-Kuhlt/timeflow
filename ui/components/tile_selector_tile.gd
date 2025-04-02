extends Panel
class_name TileSelectorTile

@onready var btn: TextureButton = $TextureButton
var idx: int
var tile_type: Shared.Tile

signal on_clicked(tile: TileSelectorTile)

func on_click_handler():
	on_clicked.emit(self)

func on_select():
	modulate = Color(0.5, 0.5, 0.5, 1.0)

func on_deselect():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
