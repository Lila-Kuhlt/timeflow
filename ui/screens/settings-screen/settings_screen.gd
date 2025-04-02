extends MarginContainer

signal exit()

func _return_to_title_screen() -> void:
	exit.emit()
	queue_free()
	Settings.save_config()
