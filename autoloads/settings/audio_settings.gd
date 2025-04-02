class_name AudioSettings

enum AudioBus {MASTER, MUSIC, SFX, VOICE}

static func _register_settings() -> void:
	Settings.add_setting("volume_master", Settings.Setting.new("Volume", 
																Settings.SettingCategory.AUDIO, 
																Settings.SettingType.FLOAT, 
																100.0, 
																{"min": 0, "max": 150, "step": 1}, 
																_set_audio_bus_volume.bind(AudioBus.MASTER)))
	Settings.add_section("section_audio_bus", "Fine Control", Settings.SettingCategory.AUDIO)
	Settings.add_setting("volume_music", Settings.Setting.new("Volume (Music)",
																Settings.SettingCategory.AUDIO,
																Settings.SettingType.FLOAT,
																100.0,
																{"min": 0, "max": 150, "step": 1},
																_set_audio_bus_volume.bind(AudioBus.MUSIC)))
	Settings.add_setting("volume_sfx", Settings.Setting.new("Volume (SFX)",
																Settings.SettingCategory.AUDIO,
																Settings.SettingType.FLOAT,
																100.0,
																{"min": 0, "max": 150, "step": 1},
																_set_audio_bus_volume.bind(AudioBus.SFX)))
	Settings.add_setting("volume_voice", Settings.Setting.new("Volume (Voice)",
																Settings.SettingCategory.AUDIO,
																Settings.SettingType.FLOAT,
																100.0,
																{"min": 0, "max": 150, "step": 1},
																_set_audio_bus_volume.bind(AudioBus.VOICE)))

static func _set_audio_bus_volume(volume: float, bus: AudioBus):
	volume = lerp(-20, 0, volume / 100.0)
	match bus:
		AudioBus.MASTER: AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)
		AudioBus.MUSIC: AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume)
		AudioBus.SFX: AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume)
		AudioBus.VOICE: AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), volume)
