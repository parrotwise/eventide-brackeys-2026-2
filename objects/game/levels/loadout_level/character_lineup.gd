class_name CharacterLineup
extends HBoxContainer


var characters: Array[Character]:
	get:
		var found: Array[Character] = []
		for anchor: Control in get_children():
			for scaler: Node2D in anchor.get_children():
				if scaler.get_child_count():
					found.append(scaler.get_child(0))
		return found


func clear() -> void:
	for character: Character in characters:
		character.get_parent().remove_child(character)


func reset() -> void:
	clear()
	
	for i: int in Game.available_characters.size():
		var character: Character = Game.available_characters[i]
		get_child(i + 1).get_child(0).add_child(character)
		character.indicators.hide()
