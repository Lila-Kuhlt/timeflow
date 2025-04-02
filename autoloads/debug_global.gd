extends Node

var debug_label : Label

var debug_dict = Dictionary()
var update_queued = true

func _ready() -> void:
	InputManager.game_debug_show.connect(_show_label)
	InputManager.game_debug_hide.connect(_hide_label)

func _show_label() -> void:
	if debug_label:
		debug_label.visible = true
		InputManager.is_debug_label_visible = true
		if debug_label == null:
			push_warning("debug label not set")
	
func _hide_label() -> void:
	if debug_label:
		debug_label.visible = false
		InputManager.is_debug_label_visible = false

func set_debug_info(key: String, value: Variant):
	debug_dict[key] = value
	update_queued = true

func reset_debug_info(key: String):
	debug_dict.erase(key)
	update_queued = true

func _process(_delta):
	if update_queued:
		if debug_label == null:
			update_queued = false
			return
		var debug_text = ""
		for key in debug_dict.keys():
			debug_text += key + ": " + str(debug_dict[key]) + "\n"
		debug_label.text = debug_text
		
		update_queued = false
		
