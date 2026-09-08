class_name CharacterEquipment
extends Node2D

@export var equipment: Array[Equipment] = []

var character: Character


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func _on_combat_start() -> void:
	if character.name in Game.inventories:
		equipment.assign(Game.inventories[character.name])
		Debug.info('Restored loadout %s for %s.' % [Game.inventories[character.name].map(func(e): return e.name), character.name])
	
	for i: int in equipment.size():
		equipment[i] = equipment[i].duplicate()
	
	for item: Equipment in equipment:
		character.state_component.apply_status(item.equipped_status)
