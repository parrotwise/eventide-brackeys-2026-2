class_name CharacterEquipment
extends Node2D

@export var equipment: Array = []

var character: Character


func _ready() -> void:
	pass


func get_inventory() -> void:
	if !Game.inventories.has(character.name):
		Game.inventories.get_or_add(character.name, [])
		return
	Debug.info(character.name + " has " + str(Game.inventories.get(character.name)))
	
	equipment = Game.inventories[character.name]
	
	for i: int in equipment.size():
		equipment[i] = equipment[i].duplicate()
