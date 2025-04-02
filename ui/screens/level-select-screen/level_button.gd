class_name LevelButton
extends Button

var level_nr: int
signal select_level(level_nr: int)

func _ready() -> void:
	text = str(level_nr)

func _on_pressed() -> void:
	select_level.emit(level_nr)
