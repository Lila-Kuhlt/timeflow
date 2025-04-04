extends Control

func on_to_title_screen() -> void:
	Global.game_manager._return_to_title_screen()
	queue_free()

func on_retry() -> void:
	Global.game_manager._reload_current_level()
	get_tree().paused = false
	queue_free()
