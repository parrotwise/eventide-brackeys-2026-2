class_name CombatCamera
extends Camera2D


var initial_position: Vector2
var zoom_level: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = position


func zoom_on_characters(chars: Array[Character]) -> void:
	var char_count: int = chars.size()
	var char_sqr: float = 480
	var avg_pos: Vector2 = Vector2.ZERO
	
	for character: Character in chars:
		avg_pos += character.position
		avg_pos /= char_count
	avg_pos.y -= char_sqr / 4
	
	zoom_level= 0.8 * get_viewport_rect().size.x / (char_sqr * char_count)
	var zoom_vector: Vector2 = Vector2(zoom_level, zoom_level)
	
	var zoom_tween = create_tween()
	zoom_tween.tween_property(self, "zoom", zoom_vector, 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	zoom_tween.parallel().tween_property(self, "position", avg_pos, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func zoom_to_full() -> void:
	var zoom_tween = create_tween()
	zoom_tween.tween_property(self, "zoom", Vector2.ONE, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	zoom_tween.parallel().tween_property(self, "position", initial_position, 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	zoom_level = 1.0


func shake_screen() -> void:
	var intensity = Settings.screen_shake_intensity / zoom_level
	
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
	if zoom_level == 1.0:
		position = initial_position
