class_name CombatCharacters
extends Node


var allies: Array[Character]:
	get: return _get_characters_in_group(&"allies")
var free_allies: Array[Character]:
	get: return Array(
		allies.filter(func(ally: Character): return ally not in Game.level.turn_tracker_component.acted_allies),
		TYPE_OBJECT, &'Node2D', Character
	)
var enemies: Array[Character]:
	get: return _get_characters_in_group(&"enemies")
var all: Array[Character]:
	get: return allies + enemies

var ally_melee: Character:
	get: return allies[-1]
var enemy_melee: Character:
	get: return enemies[0]


func is_in_melee(character: Character) -> bool:
	return character in [ally_melee, enemy_melee]


func get_adjacent_to(character: Character) -> Array[Character]:
	if character not in all:
		return []
	
	var adjacent: Array[Character] = []
	var frendos: Array[Character] = allies if character in allies else enemies
	var index: int = frendos.find(character)

	if index >= 1:
		adjacent.append(frendos[index - 1])
	if (index + 1) < frendos.size():
		adjacent.append(frendos[index + 1])
	
	return adjacent


func _get_characters_in_group(group_name: StringName) -> Array[Character]:
	var result: Array[Character] = []

	for node: Node in get_tree().get_nodes_in_group(group_name):
		if node is Character and self.is_ancestor_of(node):
			result.append(node as Character)

	return result
