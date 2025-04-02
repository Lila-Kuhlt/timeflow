extends Node

#region Helper enums and data classes

enum SettingCategory {AUDIO, CONTROLS, GRAPHICS, ACCESSIBILITY}
func category_string(cat: SettingCategory) -> String:
	match cat:
		SettingCategory.AUDIO: return "Audio"
		SettingCategory.CONTROLS: return "Controls"
		SettingCategory.GRAPHICS: return "Graphics"
		SettingCategory.ACCESSIBILITY: return "Accessibility"
		_: return "unknown category"

enum SettingType {INT, ENUM, FLOAT, BOOL, SECTION, INPUT_BINDING}

class Setting:
	signal value_changed(value: Variant)

	var label_text: String
	var category: SettingCategory
	var type: SettingType
	var value: Variant:
		set = set_value
	var default_value: Variant
	var requires_restart: bool
	var setter_callable: Callable
	var hints: Dictionary # Used for minimum/maximum values, step size, enum names
	
	func _init(p_label_text: String, p_category: SettingCategory, p_type: SettingType, p_default_value: Variant, p_hints: Dictionary = {}, p_setter_callable: Callable = Callable(), p_requires_restart: bool = false):
		self.label_text = p_label_text
		self.category = p_category
		self.type = p_type
		self.value = p_default_value
		self.default_value = p_default_value
		self.hints = p_hints
		self.setter_callable = p_setter_callable
		self.requires_restart = p_requires_restart
	
	func set_value(p_value: Variant):
		if not is_same(p_value, value):
			value = p_value
			value_changed.emit(value)
			if setter_callable.is_valid():
				setter_callable.call(value)

#endregion

var settings: Dictionary = {}

func _ready() -> void:
	AudioSettings._register_settings()
	GraphicsSettings._register_settings()
	ControlSettings._register_settings()
	AccessibilitySettings._register_settings()

#region Settings interface

func add_setting(p_name: String, p_setting: Setting) -> void:
	if settings.has(p_name):
		push_warning("Setting " + p_name + " does already exist")
	settings[p_name] = p_setting

func add_section(p_name: String, p_display_string: String, p_category: SettingCategory) -> void:
	if settings.has(p_name):
		push_warning("Setting/section " + p_name + " does already exist")
	settings[p_name] = Setting.new(p_display_string,
								   p_category,
								   SettingType.SECTION,
								   null)

func get_value(p_name: String) -> Variant:
	if settings.has(p_name):
		return settings[p_name].value
	else:
		push_warning("Setting " + p_name + " not found")
		return null

func set_value(p_name: String, p_value: Variant) -> void:
	if settings.has(p_name):
		if typeof(p_value) != typeof(settings[p_name].default_value):
			push_warning("Variant type mismatch for setting " + p_name + " (" + type_string(typeof(p_value)) + " should be " + type_string(typeof(settings[p_name].default_value)) + ")")
		settings[p_name].value = p_value
	else:
		push_warning("Setting " + name + " not found")

func set_default_value(p_name: String, p_default_value: Variant) -> void:
	if settings.has(p_name):
		if typeof(p_default_value) != typeof(settings[p_name].default_value):
			push_warning("Variant type mismatch for setting " + p_name + " (" + type_string(typeof(p_default_value)) + " should be " + type_string(typeof(settings[p_name].default_value)) + ")")
		settings[p_name].default_value = p_default_value
	else:
		push_warning("Setting " + name + " not found")

func reset_value(p_name: String):
	if settings.has(p_name):
		settings[p_name].value = settings[p_name].default_value
		if settings[p_name].setter_callable.is_valid():
			settings[p_name].setter_callable.call(settings[p_name].default_value)
	else:
		push_warning("Setting " + name + " not found")

func reset_input_binding(p_name: String, index: int):
	if settings.has(p_name):
		if settings[p_name].type == SettingType.INPUT_BINDING:
			var events = settings[p_name].value.duplicate()
			if index >= events.size():
				push_warning("Index " + str(index) + " out of bounds for input_binding setting " + p_name)
				return
			var default_event = settings[p_name].default_value[index] if index < settings[p_name].default_value.size() else null
			events[index] = default_event
			settings[p_name].value = events
			if settings[p_name].setter_callable.is_valid():
				settings[p_name].setter_callable.call(events)
		else:
			push_warning("Setting " + p_name + " is not a input_binding setting")
	else:
		push_warning("Setting " + name + " not found")

func is_value_default(p_name: String) -> bool:
	if settings.has(p_name):
		return is_equal(settings[p_name].value, settings[p_name].default_value)
	else:
		push_warning("Setting " + name + " not found")
		return false

func is_input_binding_default(p_name: String, index: int) -> bool:
	if settings.has(p_name):
		if settings[p_name].type == SettingType.INPUT_BINDING:
			var event = settings[p_name].value[index] if index < settings[p_name].value.size() else null
			var default_event = settings[p_name].default_value[index] if index < settings[p_name].default_value.size() else null
			return is_equal(event, default_event)
		else:
			push_warning("Setting " + p_name + " is not a input_binding setting")
			return false
	else:
		push_warning("Setting " + name + " not found")
		return false

func load_config():
	var config = ConfigFile.new()
	config.load("user://config.cfg")

	for setting in settings:
		if settings[setting].type == SettingType.SECTION:
			continue
		
		var value = config.get_value(category_string(settings[setting].category), setting, settings[setting].default_value)
		if value == null:
			push_warning("Setting " + setting + " not found in config file, using default value")
			continue
		if typeof(value) != typeof(settings[setting].default_value):
			push_warning("Variant type mismatch for setting " + setting + " (" + type_string(typeof(value)) + " should be " + type_string(typeof(settings[setting].default_value)) + ")")
			continue
		settings[setting].value = value
		# Call the setter function once to apply the setting
		if settings[setting].setter_callable.is_valid():
			settings[setting].setter_callable.call(value)

func save_config():
	var config = ConfigFile.new()

	for setting in settings:
		config.set_value(category_string(settings[setting].category), setting, settings[setting].value)

	config.save("user://config.cfg")

## Be cautious! Clears the config file, resetting all settings to their default values.
## This can be useful for troubleshooting.
func clear_config():
	settings.clear()
	var config = ConfigFile.new()
	config.save("user://config.cfg")

# TODO: Use the property system for settings so that autocomplete works.
#func _get_property_list() -> Array:
	#print("Getting property list")
	#var props : Array
	#for setting in settings:
		#props.append({"name": setting,
		#"type": settings[setting].type,
		#"hint": PROPERTY_HINT_NONE,
		#"hint_string": "",
		#"usage": PROPERTY_USAGE_DEFAULT})
	#return props
#
#func _set(property: StringName, value: Variant):
	#print("Setting " + property + " to " + str(value))
	#if settings.has(property):
		#settings[property].value = value
		#if settings[property].requires_restart:
			#push_warning("Changing this setting requires a restart")
	#else:
		#push_warning("Setting " + property + " not found")
#
#func _get(property: StringName) -> Variant:
	#print("Getting " + property)
	#if settings.has(property):
		#return settings[property].value
	#else:
		#push_warning("Setting " + property + " not found")
		#return null

#endregion

## Deep property based equality check for two variants
func is_equal(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false
	if typeof(a) != TYPE_DICTIONARY and typeof(a) != TYPE_OBJECT and typeof(a) != TYPE_ARRAY:
		return a == b
	if typeof(a) == TYPE_ARRAY:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not is_equal(a[i], b[i]):
				return false
		return true
	if typeof(a) == TYPE_DICTIONARY:
		# Compare all keys of the two dictionaries
		for key in a.keys():
			if not b.has(key):
				return false
			if not is_equal(a[key], b[key]):
				return false
		for key in b.keys():
			if not a.has(key):
				return false
		return true
	# Both are objects, compare all properties
	for prop in a.get_property_list():
		if not is_equal(a.get(prop.name), b.get(prop.name)):
			return false
	return true
