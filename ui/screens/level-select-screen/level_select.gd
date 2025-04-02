extends Control

@export var buttonContainer: Container

var level_buttons: Array[Button] = []
var completed_levels: Array[bool] = []

signal start_level(level_nr: int)
signal test_level()
signal exit()

func init_buttons(max_level: int, completed_level_information: Array[bool]) -> void:
	if max_level > 0:
		$VBoxContainer/Label.visible = false
	
	completed_levels = completed_level_information
	for i in range(max_level):
		var b: LevelButton = load("res://ui/screens/level-select-screen/level_button.tscn").instantiate()
		b.level_nr = i + 1
		b.select_level.connect(_level_button_pressed)
		b.disabled = not completed_levels[i]
		level_buttons.append(b)
		buttonContainer.add_child(b)

func _level_button_pressed(level_nr: int) -> void:
	print("Start Level ",level_nr)
	start_level.emit(level_nr)
	queue_free()
	
func _return_to_title() -> void:
	exit.emit()
	queue_free()

func _on_unlock_levels_toggled(toggled_on: bool) -> void:
	for i in range(len(level_buttons)):
		if toggled_on:
			level_buttons[i].disabled = false
		else:
			level_buttons[i].disabled = !completed_levels[i]

func _on_test_level_pressed() -> void:
	test_level.emit()
	queue_free()
