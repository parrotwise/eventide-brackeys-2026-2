class_name CharacterActions
extends Node


@export var basic_attack: Action
@export var reposition: Action
@export var skills: Array[Action] = []

var actions: Array[Action]:
	get: return Array([basic_attack, reposition], TYPE_OBJECT, &'Resource', Action) + skills

var character: Character


func _ready() -> void:
	Game.start.connect(_on_combat_start)

	basic_attack = basic_attack.duplicate()
	reposition = reposition.duplicate()
	
	for i: int in skills.size():
		skills[i] = skills[i].duplicate()


func _on_combat_start() -> void:
	basic_attack.owner = character
	reposition.owner = character

	for skill: Action in skills:
		skill.owner = character
