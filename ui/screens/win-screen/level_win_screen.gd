class_name LevelWinScreen
extends Control

@onready var count: Label = $CountLabel
@onready var text_label: Label = $CenterContainer/VBoxContainer/Label

func _on_next_button_pressed() -> void:
	Global.game_manager._next_level()
	get_tree().paused = false
	queue_free()

func _on_back_button_pressed() -> void:
	Global.game_manager._return_to_title_screen()
	queue_free()
