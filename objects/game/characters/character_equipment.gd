class_name CharacterEquipment
extends Node2D

@export var equipment: Array[Equipment] = []

var character: Character


func _ready() -> void:
	Game.combat_start.connect(_on_combat_start)
	Game.combat_end.connect(_on_combat_end)


func _on_combat_start() -> void:
	if character.id in Game.inventories:
		equipment.assign(Game.inventories[character.id])
		Debug.info('Restored loadout %s for %s.' % [Game.inventories[character.id].map(func(e): return e.name), character.id])
	
	for i: int in equipment.size():
		equipment[i] = equipment[i].duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	for item: Equipment in equipment:
		character.state.apply_status(item.equipped_status)


func _on_combat_end() -> void:
	if character not in Game.available_characters and character.id in Game.inventories:
		Game.inventories[character.id].clear()
