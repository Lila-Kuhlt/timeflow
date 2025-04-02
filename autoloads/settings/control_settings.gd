class_name ControlSettings

static func create_action_setting(action: String, label: String) -> void:
	var events = InputMap.action_get_events(action)
	var default_events = []
	for i in range(2):
		if i < events.size():
			default_events.append(events[i])
		else:
			default_events.append(null)

	var setting_key = "action_map_" + action

	Settings.add_setting(setting_key, Settings.Setting.new(label,
														Settings.SettingCategory.CONTROLS,
														Settings.SettingType.INPUT_BINDING,
														events,
														{"action": action},
														set_input_events.bind(action)))	
	
static func _register_settings() -> void:
	Settings.add_setting("mouse_sensitivity", Settings.Setting.new("Mouse Sensitivity",
																	Settings.SettingCategory.CONTROLS,
																	Settings.SettingType.FLOAT,
																	1.0,
																	{"min": 0.1, "max": 1.9, "step": 0}))
	Settings.add_section("section_controls_key_bindings", "Key Bindings", Settings.SettingCategory.CONTROLS)
	# Insert you remappable actions here
	create_action_setting("move_up", "Move Forward")
	create_action_setting("move_down", "Move Backward")
	create_action_setting("move_left", "Move Left")
	create_action_setting("move_right", "Move Right")


static func set_input_events(events: Array, action: String) -> void:
	InputMap.action_erase_events(action)
	for event in events:
		InputMap.action_add_event(action, event)