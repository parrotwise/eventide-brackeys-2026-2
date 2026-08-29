extends CanvasLayer


#const intro_narrative: String = ""
#const betrayal_narrative: String = ""
#const loot_level: String = ""
const combat_level: String = "res://objects/game/levels/combat_level/combat_level.tscn"

var blindfold: ColorRect:
	get: return $ColorRect


func _ready() -> void:
	blindfold.modulate.a = 0


func simple_fade(scene_path: String) -> void:
	var transition_tween = create_tween()
	transition_tween.tween_property(blindfold, "modulate:a", 1, 0.2)
	
	await transition_tween.finished
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().scene_changed
	transition_tween.stop()	# idk why you have to stop() it first, but you do.
	transition_tween.tween_property(blindfold, "modulate:a", 0, 0.2)
	transition_tween.play()
