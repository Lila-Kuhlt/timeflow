extends Control

func on_to_title_screen() -> void:
	queue_free()

func on_retry() -> void:
	var gm: GameManager = $"/root/Gamemanager"
	gm._reload_current_level()
	gm.resume()
	queue_free()
