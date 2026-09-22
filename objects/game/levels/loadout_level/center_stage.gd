class_name CenterStage
extends Control


var selected: Character:
	get: return Game.loadout.selector.current_character


func refresh() -> void:
	if not is_instance_valid(selected):
		return
	
	for child in get_children():
		child.queue_free()
	
	var actor: Actor = selected.actor.duplicate()
	actor.scale *= 1.3

	add_child(actor)
