extends Control


var panel_1: TextureRect:
	get: return $VBoxContainer/HBoxContainer/Panel1
var panel_2: TextureRect:
	get: return $VBoxContainer/HBoxContainer/Panel2
var panel_3: TextureRect:
	get: return $VBoxContainer/Panel3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	get_panel_1()
	await get_tree().create_timer(2).timeout
	get_panel_2()
	await get_tree().create_timer(2).timeout
	get_panel_3()
	
	await get_tree().create_timer(3).timeout
	TransitionLayer.transition_betrayal(TransitionLayer.combat_level)


func get_panel_1() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(panel_1, "offset_transform_position", Vector2(0, 0), 0.8)


func get_panel_2() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(panel_2, "offset_transform_position", Vector2(0, 0), 0.4)


func get_panel_3() -> void:
	
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_3, "offset_transform_position", Vector2(0, 0), 2)
