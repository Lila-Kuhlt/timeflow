extends Control

func _ready() -> void:
	if Shared.SKIP_TITLE_SCREEN:
		queue_free()

func _on_continue_pressed() -> void:
	queue_free()
