class_name CharacterActions
extends Node


@export var basic_attack: Action
@export var reposition: Action
@export var skills: Array[Action] = []

var actions: Array[Action]:
	get: return Array([basic_attack, reposition], TYPE_OBJECT, &'Resource', Action) + skills + granted_actions
var granted_actions: Array[Action]:
	get: return Array(
		character.state_component.active_statuses.reduce(func(accum, s): return accum + s.granted_actions, []),
		TYPE_OBJECT, &'Resource', Action
	)

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
	
	Game.level.turn_tracker_component.battle_group_started.connect(_on_battle_group_started)

	for action: Action in actions:
		action.restore_uses()


func _on_battle_group_started(group_name: StringName) -> void:
	if group_name != character.battle_group:
		return
	
	for action: Action in actions:
		action.restore_uses()
