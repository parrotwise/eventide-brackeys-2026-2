class_name CombatCharacters
extends Node


var allies: Array[Character]:
	get: return Array($Allies.get_children(), TYPE_OBJECT, &'Node2D', Character)
var free_allies: Array[Character]:
	get: return Array(
		allies.filter(func(ally: Character): return ally not in Game.level.turn_tracker_component.acted_allies),
		TYPE_OBJECT, &'Node2D', Character
	)
var enemies: Array[Character]:
	get: return Array($Enemies.get_children(), TYPE_OBJECT, &'Node2D', Character)
var all: Array[Character]:
	get: return allies + enemies

var ally_melee: Character:
	get: return allies[0]
var ally_rear: Character:
	get: return allies[-1]
var enemy_melee: Character:
	get: return enemies[0]
var enemy_rear: Character:
	get: return enemies[-1]


var ally_selected_indicator: Sprite2D:
	get: return $AllySelectedIndicator
var enemy_targeted_indicator: Sprite2D:
	get: return $EnemyTargetedIndicator


func _process(_delta: float) -> void:
	for character: Character in all:
		character.sprite.flip_h = character in enemies
		character.input_component.set_flip(character in enemies)


func target_position(character: Character) -> Vector2:
	if character not in all:
		return Vector2.ZERO
	
	if character in allies:
		return $SpawnPoints/Allies.get_children()[index_of(character)].position
	if character in enemies:
		return $SpawnPoints/Enemies.get_children()[index_of(character)].position
	
	return Vector2.ZERO


func is_in_melee(character: Character) -> bool:
	return character in [ally_melee, enemy_melee]


func is_at_rear(character: Character) -> bool:
	return character in [ally_rear, enemy_rear]


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


func index_of(character: Character) -> int:
	if character not in all:
		return -1
	
	if character in allies:
		return allies.find(character)
	
	return enemies.find(character)


func are_adjacent(char1: Character, char2: Character) -> bool:
	if char1 not in all or char2 not in all:
		return false
	
	if char1.battle_group != char2.battle_group:
		return false
	
	return absi(index_of(char1) - index_of(char2)) == 1


func swap_places(char1: Character, char2: Character) -> void:
	if char1 not in all or char2 not in all:
		return
	
	if char1.battle_group != char2.battle_group:
		return
	
	var index1: int = index_of(char1)
	var index2: int = index_of(char2)

	if index1 < index2:
		char2.get_parent().move_child(char2, index1)
		char1.get_parent().move_child(char1, index2)
	else:
		char1.get_parent().move_child(char1, index2)
		char2.get_parent().move_child(char2, index1)


func move_forward(character: Character) -> void:
	_move_by(+1, character)


func move_backward(character: Character) -> void:
	_move_by(-1, character)


func _move_by(steps: int, character: Character) -> void:
	if character not in all:
		return
	
	var frendos: Array[Character] = allies if character in allies else enemies
	var current_index: int = frendos.find(character)
	var new_index: int = current_index + steps

	if new_index >= 0 and new_index < frendos.size():
		character.get_parent().move_child(character, new_index)
