class_name CharacterLineup
extends HBoxContainer


var characters: Array[Character]:
	get:
		var found: Array[Character] = []
		for anchor: Control in get_children():
			if anchor.get_child_count() > 1:
				var scaler := anchor.get_child(1) as Node2D
				if scaler.get_child_count():
					found.append(scaler.get_child(0) as Character)
		return found


func _ready() -> void:
	for anchor: Control in get_children():
		if anchor.get_child_count() <= 1:
			continue
		
		var frame := anchor.get_child(0) as TextureButton

		for conn: Dictionary in frame.pressed.get_connections():
			frame.pressed.disconnect(conn['callable'])

		frame.pressed.connect(func():
			var scaler := frame.get_parent().get_child(-1) as Node2D

			if scaler.get_child_count():
				scaler.get_child(0).input.submit_as_target()
		)


func clear() -> void:
	for character: Character in characters:
		character.get_parent().remove_child(character)


func reset() -> void:
	clear()
	
	for i: int in Game.available_characters.size():
		var character: Character = Game.available_characters[i]
		get_child(i + 1).get_child(1).add_child(character)

		character.position = Vector2.ZERO
		character.indicators.visible = Game.stage != Game.Stage.LOADOUT1
	
	for i: int in get_child_count():
		get_child(i).visible = i <= Game.available_characters.size()
