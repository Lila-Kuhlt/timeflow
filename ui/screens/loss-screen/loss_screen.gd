extends Control


func _on_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
