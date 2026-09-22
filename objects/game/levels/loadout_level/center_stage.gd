class_name CenterStage
extends Control


var selected: Character:
	get: return Game.loadout.selector.current_character


func refresh() -> void:
	if not is_instance_valid(selected):
		return
	
	for child in get_children():
		child.queue_free()
	
	add_child(selected.actor.duplicate())
