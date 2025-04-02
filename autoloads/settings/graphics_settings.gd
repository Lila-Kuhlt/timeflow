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
	Settings.add_setting("3d_aa_mode", Settings.Setting.new("3D Anti-Aliasing Mode",
						   Settings.SettingCategory.GRAPHICS,
						   Settings.SettingType.ENUM,
						   AAMode_3D.DISABLED,
						   {"options": ["Disabled", "FXAA", "TAA", "MSAA 2x", "MSAA 4x", "FSR 2"]},
						   _set_aa_mode_3d))
	# 2D MSAA is not yet available in the Compatibility renderer
	if (ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method") != "gl_compatibility"):
		Settings.add_setting("2d_aa_mode", Settings.Setting.new("2D Anti-Aliasing Mode",
							Settings.SettingCategory.GRAPHICS,
							Settings.SettingType.ENUM,
							AAMode_3D.DISABLED,
							{"options": ["Disabled", "MSAA 2x", "MSAA 4x", "MSAA 8x"]},
							_set_aa_mode_2d))

static func _set_display_mode(display_mode: DisplayMode):
	match display_mode:
		DisplayMode.FULLSCREEN:
			Global.game_manager.get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		DisplayMode.WINDOWED_FULLSCREEN:
			Global.game_manager.get_window().mode = Window.MODE_FULLSCREEN
		DisplayMode.WINDOWED:
			Global.game_manager.get_window().mode = Window.MODE_WINDOWED

static func _set_aa_mode_3d(mode: AAMode_3D):
	var vp = Global.game_manager.get_viewport()
	vp.use_taa = false
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	vp.msaa_3d = Viewport.MSAA_DISABLED
	vp.msaa_2d = Viewport.MSAA_DISABLED
	vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	match mode:
		AAMode_3D.FXAA: vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		AAMode_3D.TAA: vp.use_taa = true
		AAMode_3D.MSAA_2X: vp.msaa_3d = Viewport.MSAA_2X
		AAMode_3D.MSAA_4X: vp.msaa_3d = Viewport.MSAA_4X
		AAMode_3D.FSR_2: vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2

static func _set_aa_mode_2d(mode: AAMode_2D):
	var vp = Global.game_manager.get_viewport()
	vp.msaa_2d = Viewport.MSAA_DISABLED
	match mode:
		AAMode_2D.MSAA_2X: vp.msaa_2d = Viewport.MSAA_2X
		AAMode_2D.MSAA_4X: vp.msaa_2d = Viewport.MSAA_4X
		AAMode_2D.MSAA_8X: vp.msaa_2d = Viewport.MSAA_8X
