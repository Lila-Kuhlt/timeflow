extends Control

@onready var count: Label = $Totalcount
@onready var comment: Label = $Comment

func _on_button_pressed() -> void:
	queue_free()
