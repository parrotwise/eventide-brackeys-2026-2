extends CanvasLayer


signal transition_finished()


const cutscene_1: String = "res://objects/game/levels/cutscenes/cutscene_1.tscn"
const equipment_level: String = "res://objects/game/levels/equipment_level/equipment_level.tscn"
const cutscene_3: String = "res://objects/game/levels/cutscenes/cutscene_3.tscn"
const cutscene_4: String = "res://objects/game/levels/cutscenes/cutscene_4.tscn"
const combat_level: String = "res://objects/game/levels/combat_level/combat_level.tscn"
const cutscene_6: String = ""
const cutscene_7: String = ""
const cutscene_9: String = ""
const cutscene_10: String = ""
const cutscene_11: String = ""

var blindfold: ColorRect:
	get: return $ColorRect
var betrayal: Control:
	get: return $Betrayal


func _ready() -> void:
	blindfold.modulate.a = 0
	betrayal.hide()


func transition_simple_fade(scene_path: String) -> void:
	var transition_tween = create_tween()
	transition_tween.tween_property(blindfold, "modulate:a", 1, 0.2)
	
	await transition_tween.finished
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().scene_changed
	await get_tree().create_timer(0.1).timeout
	var new_transition_tween = create_tween()
	new_transition_tween.tween_property(blindfold, "modulate:a", 0, 0.2)
	new_transition_tween.parallel().tween_property(betrayal, "modulate:a", 0, 0.2)
	
	transition_finished.emit()


func transition_betrayal(scene_path: String) -> void:
	betrayal.modulate.a = 0
	betrayal.show()
	
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(betrayal, "modulate:a", 1, 0.2)
	
	await tween.finished
	await get_tree().create_timer(0.5)
	transition_simple_fade(scene_path)
