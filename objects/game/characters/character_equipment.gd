class_name CharacterEquipment
extends Node2D

@export var equipment: Array[Equipment] = []

var character: Character


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func _on_combat_start() -> void:
	if character.id in Game.inventories:
		equipment.assign(Game.inventories[character.id])
		Debug.info('Restored loadout %s for %s.' % [Game.inventories[character.id].map(func(e): return e.name), character.id])
	
	for i: int in equipment.size():
		equipment[i] = equipment[i].duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	for item: Equipment in equipment:
		character.state_component.apply_status(item.equipped_status)
