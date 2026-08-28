class_name CharacterActions
extends Node


@export var basic_attack: Action
@export var reposition: Action
@export var skills: Array[Action] = []

var actions: Array[Action]:
	get: return Array([basic_attack, reposition], TYPE_OBJECT, &'Resource', Action) + skills

var character: Character


func _ready() -> void:
	basic_attack = basic_attack.duplicate()
	reposition = reposition.duplicate()
	
	for i: int in actions.size():
		actions[i] = actions[i].duplicate()
