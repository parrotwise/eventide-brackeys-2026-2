extends Control


var text_betr: TextureRect:
	get: return $CenterContainer/HBoxContainer2/BETR
var text_ayal: TextureRect:
	get: return $CenterContainer/HBoxContainer2/AYAL
var bg_left: TextureRect:
	get: return $CenterContainer/HBoxContainer/LeftBG
var bg_right: TextureRect:
	get: return $CenterContainer/HBoxContainer/RightBG


@export var exaggeration: float = 48
var wobble: Vector2 = Vector2(exaggeration, exaggeration)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shake_text()
	shake_bg()


func shake_text() -> void:
	var left_tween = create_tween().set_trans(Tween.TRANS_CIRC)
	var right_tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	left_tween.set_loops()
	left_tween.tween_property(text_betr, "position", wobble, 0.2).as_relative()
	left_tween.tween_property(text_betr, "position", -wobble, 0.2).as_relative()
	
	right_tween.set_loops()
	right_tween.tween_property(text_ayal, "position", -wobble, 0.2).as_relative()
	right_tween.tween_property(text_ayal, "position", wobble, 0.2).as_relative()


func shake_bg() -> void:
	var left_tween = create_tween().set_trans(Tween.TRANS_CIRC)
	var right_tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	left_tween.set_loops()
	left_tween.tween_property(bg_left, "position", wobble.rotated(deg_to_rad(90)), 0.2).as_relative()
	left_tween.tween_property(bg_left, "position", -wobble.rotated(deg_to_rad(90)), 0.2).as_relative()
	
	right_tween.set_loops()
	right_tween.tween_property(bg_right, "position", -wobble.rotated(deg_to_rad(90)), 0.2).as_relative()
	right_tween.tween_property(bg_right, "position", wobble.rotated(deg_to_rad(90)), 0.2).as_relative()
