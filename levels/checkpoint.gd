extends Node2D

@onready var flag : Sprite2D = $Flag 

func _ready() -> void:
	var level: Level = self.get_node("../..")
	var coords: Vector2i = level.checkpoint_map.local_to_map(position)
	
	var colors: Array[Color] = [
		Color.from_string("8b0000", Color.WHITE),
		Color.from_string("00008b", Color.WHITE),
		Color.from_string("e9967a", Color.WHITE),
		Color.from_string("b03060", Color.WHITE),
		Color.from_string("ff4500", Color.WHITE),
		Color.from_string("ffa500", Color.WHITE),
		Color.from_string("ffff00", Color.WHITE),
		Color.from_string("1e90ff", Color.WHITE),
		Color.from_string("f0e68c", Color.WHITE),
		Color.from_string("dda0dd", Color.WHITE)
		]
	
	for i in range(level.checkpoint_groups.size()):
		if coords in level.checkpoint_groups[i]:
			self.get_node("Flag").modulate = colors[i]
						
	Global.game_manager.current_level_node.connect('reached', func(coord): flag_animation(coord, coords))
	
func flag_animation(coord, coords):
	if coord == coords: $AnimationPlayer.play("reached")
