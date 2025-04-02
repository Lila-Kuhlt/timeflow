extends Button

var event_idx = 0

signal action_changed(action: String)

func _ready():
	set_process_unhandled_key_input(false)

func _toggled(b_pressed):
	set_process_unhandled_key_input(b_pressed)
	if b_pressed:
		text = "..."
		release_focus()

func _input(event):
	if not button_pressed:
		return

	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
		action_changed.emit(event)
		get_viewport().set_input_as_handled()
		button_pressed = false

func _display_event(event: InputEvent):
	if event == null:
		text = "Unassigned"
	else:
		text = event.as_text()
	tooltip_text = text

func set_event(event: InputEvent):
	_display_event(event)
