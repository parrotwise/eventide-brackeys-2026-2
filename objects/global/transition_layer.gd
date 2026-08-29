extends CanvasLayer


#const intro_narrative: String = ""
#const betrayal_narrative: String = ""
const equipment_level: String = "res://objects/game/levels/equipment_level/equipment_level.tscn"
const combat_level: String = "res://objects/game/levels/combat_level/combat_level.tscn"

var blindfold: ColorRect:
	get: return $ColorRect


func _ready() -> void:
	blindfold.modulate.a = 0


func simple_fade(scene_path: String) -> void:
	var transition_tween = create_tween()
	transition_tween.tween_property(blindfold, "modulate:a", 1, 0.2)
	
	await transition_tween.finished
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().scene_changed
	await get_tree().create_timer(0.1).timeout
	var new_transition_tween = create_tween()
	new_transition_tween.tween_property(blindfold, "modulate:a", 0, 0.2)
