class_name ActionsComponent
extends Node


@export var actions: Array[Action] = []

var character: Character


func _ready() -> void:
	for i: int in actions.size():
		actions[i] = actions[i].duplicate()
