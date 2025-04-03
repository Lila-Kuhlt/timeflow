extends Panel
class_name TileSelectorTile

@onready var btn: TextureButton = $TextureButton
@onready var count_label: Label = $CountLabel
var idx: int
var tile_type: Shared.Tile
var count: int

signal on_clicked(tile: TileSelectorTile)

func set_tile_type(ty: Shared.Tile):
	tile_type = ty
	var coord: Vector2i = Level.get_tile_atlas_coords_from_enums(ty, Shared.Rotation.UP)
	btn.texture_normal.region = Rect2(Vector2(coord * 32), Vector2(32, 32))

func set_tile_count(v: int):
	count = v
	if v < 0:
		count_label.text = '∞'
	else:
		count_label.text = str(v)

func on_click_handler():
	on_clicked.emit(self)

func on_select():
	modulate = Color(0.5, 0.5, 0.5, 1.0)

func on_deselect():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
