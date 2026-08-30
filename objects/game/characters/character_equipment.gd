class_name CharacterEquipment
extends Node2D

@export var equipment: Array[Equipment] = []

var character: Character


func _ready() -> void:
	pass


func get_inventory() -> void:
	if !Game.inventories.has(character.name):
		Debug.info(character.name + " has no equipment.")
		return
	
	equipment = Game.inventories[character.name]
	
	for i: int in equipment.size():
		equipment[i] = equipment[i].duplicate()
