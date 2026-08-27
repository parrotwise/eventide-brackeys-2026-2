class_name CombatCharacters
extends Node


var allies: Array[Character]:
	get: return _get_characters_in_group(&"allies")
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


func _get_characters_in_group(group_name: StringName) -> Array[Character]:
	var result: Array[Character] = []

	for node: Node in get_tree().get_nodes_in_group(group_name):
		if node is Character and self.is_ancestor_of(node):
			result.append(node as Character)

	return result
