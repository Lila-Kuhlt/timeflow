extends TabContainer

@onready var action_remapping_button_scene: PackedScene = load("res://ui/components/settings-menu/action-remapping-button/action_remapping_button.tscn")

func _ready() -> void:
	_populate_menu()

func _populate_menu() -> void:
	var tc: TabContainer = self
	for category in Settings.SettingCategory.values():
		var margin_container = MarginContainer.new()
		tc.add_child(margin_container)
		tc.set_tab_title(category, Settings.category_string(category))
		
		var scroll_container = ScrollContainer.new()
		scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		margin_container.add_child(scroll_container)
		
		var margin_container2 = MarginContainer.new()
		margin_container2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin_container2.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll_container.add_child(margin_container2)

		var cat_vbox = VBoxContainer.new()
		cat_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cat_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		margin_container2.add_child(cat_vbox)

		# Add settings of the category
		for setting_key in Settings.settings:
			if Settings.settings[setting_key].category != category:
				continue
			
			var setting: Settings.Setting = Settings.settings[setting_key]

			# Check if its a section label
			if setting.type == Settings.SettingType.SECTION:
				var lbl_section_title = Label.new()
				lbl_section_title.text = setting.label_text
				lbl_section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				lbl_section_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				lbl_section_title.theme_type_variation = "SettingsGroupLabel"
				cat_vbox.add_child(lbl_section_title)
				cat_vbox.add_child(HSeparator.new())
				continue

			var hbox = HBoxContainer.new()
			hbox.custom_minimum_size = Vector2(0, 40)
			cat_vbox.add_child(hbox)
			
			# Another HBoxContainer for the label and revert button
			var hbox_lbl = HBoxContainer.new()
			hbox_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(hbox_lbl)
			
			# Label for the name of the setting
			var lbl_name = Label.new()
			lbl_name.text = setting.label_text
			lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox_lbl.add_child(lbl_name)
			
			# Revert button for changing the setting back to its default value
			# For input bindings we need to create a new button for each remapping later
			if setting.type != Settings.SettingType.INPUT_BINDING and setting.type != Settings.SettingType.SECTION:
				var revert_btn = Button.new()
				revert_btn.icon = get_theme_icon("icon", "RevertButton")
				revert_btn.custom_minimum_size = Vector2(32, 32)
				revert_btn.theme_type_variation = "FlatButton"
				revert_btn.connect("pressed", Callable.create(Settings, "reset_value").bind(setting_key))
				hbox_lbl.add_child(revert_btn)
				setting.value_changed.connect(_update_revert_button.bind(setting_key, revert_btn))
				_update_revert_button(null, setting_key, revert_btn)

			# TODO: Tooltip
			
			# Setting-specific editor
			var setting_value = setting.value
			if setting.type == Settings.SettingType.FLOAT or setting.type == Settings.SettingType.INT:
				var slider = HSlider.new()
				slider.min_value = setting.hints["min"]
				slider.max_value = setting.hints["max"]
				slider.step = setting.hints["step"]
				slider.value = setting_value
				slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				slider.size_flags_vertical = Control.SIZE_FILL
				slider.connect("value_changed", setting.set_value)
				setting.value_changed.connect(slider.set_value_no_signal)
				hbox.add_child(slider)
			elif setting.type == Settings.SettingType.BOOL:
				var checkbox = CheckBox.new()
				checkbox.button_pressed = setting_value
				checkbox.connect("toggled", setting.set_value)
				setting.value_changed.connect(checkbox.set_pressed_no_signal)
				hbox.add_child(checkbox)
			elif setting.type == Settings.SettingType.ENUM:
				var option_button = OptionButton.new()
				for i in range(setting.hints["options"].size()):
					option_button.add_item(setting.hints["options"][i], i)
				option_button.selected = setting_value
				option_button.connect("item_selected", setting.set_value)
				setting.value_changed.connect(option_button.select)
				hbox.add_child(option_button)
			elif setting.type == Settings.SettingType.INPUT_BINDING:
				
				# First reset button
				var input_revert_btn_1 = Button.new()
				input_revert_btn_1.icon = get_theme_icon("icon", "RevertButton")
				input_revert_btn_1.custom_minimum_size = Vector2(32, 32)
				input_revert_btn_1.theme_type_variation = "FlatButton"
				input_revert_btn_1.connect("pressed",Callable.create(Settings, "reset_input_binding").bind(setting_key, 0))
				hbox.add_child(input_revert_btn_1)
				setting.value_changed.connect(_update_input_mapping_revert_button_1.bind(setting_key, input_revert_btn_1))
				_update_input_mapping_revert_button_1(null, setting_key, input_revert_btn_1)
				
				# First remapping button
				var remapping_btn1 = action_remapping_button_scene.instantiate()
				remapping_btn1.set_event(setting_value[0] if setting_value.size() > 0 else null)
				remapping_btn1.connect("action_changed", _keymap_changed.bind(0, setting.hints["action"]))
				setting.value_changed.connect(_update_remapping_button1.bind(remapping_btn1))
				hbox.add_child(remapping_btn1)

				# Second reset button
				var input_revert_btn_2 = Button.new()
				input_revert_btn_2.icon = get_theme_icon("icon", "RevertButton")
				input_revert_btn_2.custom_minimum_size = Vector2(32, 32)
				input_revert_btn_2.theme_type_variation = "FlatButton"
				input_revert_btn_2.connect("pressed", Callable.create(Settings, "reset_input_binding").bind(setting_key, 1))
				hbox.add_child(input_revert_btn_2)
				setting.value_changed.connect(_update_input_mapping_revert_button_2.bind(setting_key, input_revert_btn_2))
				_update_input_mapping_revert_button_2(null, setting_key, input_revert_btn_2)

				# Second remapping button
				var remapping_btn2 = action_remapping_button_scene.instantiate()
				remapping_btn2.set_event(setting_value[1] if setting_value.size() > 1 else null)
				remapping_btn2.connect("action_changed", _keymap_changed.bind(1, setting.hints["action"]))
				setting.value_changed.connect(_update_remapping_button2.bind(remapping_btn2))
				hbox.add_child(remapping_btn2)
			else:
				print("Unknown setting type: " + str(typeof(setting_value)))

func _keymap_changed(event: InputEvent, event_idx: int, action: String) -> void:
	var setting_key = "action_map_" + action
	var events = Settings.get_value(setting_key).duplicate()
	if event_idx >= events.size():
		events.push_back(null)
	events[event_idx] = event
	print("Keymap changed " + str(event_idx) + ":" + str(events))
	Settings.set_value(setting_key, events)

func _update_revert_button(__, p_setting: String, button: Button) -> void:
	button.visible = not Settings.is_value_default(p_setting)

# Hack since callables with different binds are considered equal.
func _update_remapping_button1(value: Array[InputEvent], btn: Button):
	btn.set_event(value[0] if value.size() > 0 else null)
func _update_input_mapping_revert_button_1(__, p_setting: String, button: Button) -> void:
	button.modulate = Color.WHITE if not Settings.is_input_binding_default(p_setting, 0) else Color.TRANSPARENT

func _update_remapping_button2(value: Array[InputEvent], btn: Button):
	btn.set_event(value[1] if value.size() > 1 else null)
func _update_input_mapping_revert_button_2(__, p_setting: String, button: Button) -> void:
	button.modulate = Color.WHITE if not Settings.is_input_binding_default(p_setting, 1) else Color.TRANSPARENT

func _reset_setting(p_setting: String) -> void:
	Settings.reset_value(p_setting)
