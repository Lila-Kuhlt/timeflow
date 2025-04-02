class_name GraphicsSettings

enum DisplayMode {FULLSCREEN, WINDOWED_FULLSCREEN, WINDOWED}
enum GraphicsPreset {LOW, HIGH}
enum AAMode_3D {DISABLED, FXAA, TAA, MSAA_2X, MSAA_4X, FSR_2}
enum AAMode_2D {DISABLED, MSAA_2X, MSAA_4X, MSAA_8X}
enum ShadowQuality {DISABLED, LOW, MIDDLE, HIGH, ULTRA}

static func _register_settings() -> void:
	Settings.add_setting("display_mode", Settings.Setting.new("Display Mode",
								   Settings.SettingCategory.GRAPHICS,
								   Settings.SettingType.ENUM,
								   DisplayMode.WINDOWED_FULLSCREEN,
								   {"options": ["Fullscreen", "Windowed Fullscreen", "Windowed"]},
								   _set_display_mode))

static func _set_display_mode(display_mode: DisplayMode):
	match display_mode:
		DisplayMode.FULLSCREEN:
			Global.game_manager.get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		DisplayMode.WINDOWED_FULLSCREEN:
			Global.game_manager.get_window().mode = Window.MODE_FULLSCREEN
		DisplayMode.WINDOWED:
			Global.game_manager.get_window().mode = Window.MODE_WINDOWED
