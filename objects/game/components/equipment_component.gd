class_name EquipmentComponent
extends Node2D

@export var equipment: Array[Equipment] = []

var character: Character


func _ready() -> void:
	for i: int in equipment.size():
		equipment[i] = equipment[i].duplicate()
