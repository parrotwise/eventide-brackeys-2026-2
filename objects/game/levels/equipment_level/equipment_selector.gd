class_name EquipmentSelector
extends Node


signal character_selected(
	character: Character
)

var current_character: Character


func _ready() -> void:
	Game.equipment_start.connect(_on_equipment_start)


func select_character(character: Character) -> void:
	if not is_instance_valid(character):
		return
	
	if current_character == character:
		return
	
	current_character = character

	character_selected.emit(current_character)


func cycle_through_characters(direction := Enums.Direction.RIGHT) -> void:
	var characters: Array[Character] = Game.equipment.characters
	
	if not characters:
		return
	
	if not current_character:
		select_character(characters[0])
	
	else:
		var index: int = characters.find(current_character)

		if direction == Enums.Direction.RIGHT:
			index = (index - 1) % characters.size()
		elif direction == Enums.Direction.LEFT:
			index = (index + 1) % characters.size()
		
		select_character(characters[index])


func _on_equipment_start() -> void:
	current_character = null
	
	for character: Character in Game.equipment.characters:
		character.input.submitted.connect(select_character)
	
	cycle_through_characters(Enums.Direction.RIGHT)
