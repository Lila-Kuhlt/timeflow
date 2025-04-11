extends Node2D

@export var start_pos: Vector2
@export var end_pos: Vector2
@export var speed := 50.0
@export var scheiss_lower := 1.0 ## lower time for the timer
@export var scheiss_upper := 2.0 ## upper time for the timer

var last_pos: Vector2

@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var scheiss_timer: Timer = $ScheissTimer
@onready var scheisse_audio: AudioStreamPlayer = $ScheisseAudioPlayer
@onready var sprite: AnimatedSprite2D = $Path2D/PathFollow2D/VogelNodePosition/AnimatedSprite2D

func _ready() -> void:
	path.curve.set_point_position(0, start_pos)
	path.curve.set_point_position(1, end_pos)
	path.curve.set_point_position(2, start_pos)
	sprite.play()
	scheiss_timer.wait_time = randf_range(scheiss_lower, scheiss_upper)
	scheiss_timer.start()

func _process(delta: float) -> void:
	path_follow.progress += delta * speed
	var angle = (last_pos - path_follow.position).angle()
	sprite.rotation = angle
	sprite.scale.y = 1 if abs(angle) <= PI / 2 else -1
	last_pos = path_follow.position


func on_scheiss_timer_timeout() -> void:
	var parent: Level = get_parent()
	parent.drauf_scheissen(path_follow.global_position)
	scheisse_audio.play(0.13)
	scheiss_timer.wait_time = randf_range(scheiss_lower, scheiss_upper)
