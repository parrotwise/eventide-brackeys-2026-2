class_name CombatCamera
extends Camera2D


var initial_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func zoom_on_characters(chars: Array[Character]) -> void:
	pass


func shake_screen() -> void:
	var intensity = Settings.screen_shake_intensity
	
	# If the screen shake intensity is null or 0, skip the method.
	if !intensity or intensity == 0:
		return
	
	# Pick a random direction to jiggle the screen.
	var rand_angle: float = randf_range(0, 359.9)
	var shake_vector: Vector2 = Vector2.ONE.rotated(deg_to_rad(rand_angle))
	shake_vector *= intensity * 42
	
	# Shaky shaky shaky
	var shake_tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	shake_tween.set_loops(2)
	shake_tween.tween_property(self, "position", shake_vector, 0.06).as_relative()
	shake_tween.tween_property(self, "position", -shake_vector, 0.06).as_relative()
	
	# Reset offset.
	await shake_tween.finished
	position = initial_position
