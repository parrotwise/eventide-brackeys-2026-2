class_name CombatTurnTracker
extends Node


signal round_started(round_number: int)
signal battle_group_started(group_name: StringName)
signal turn_started(character: Character)
signal turn_lost(character: Character)
signal turn_ended(character: Character)


const ALLIES_GROUP: StringName = &"allies"
const ENEMIES_GROUP: StringName = &"enemies"


var allies: Array[Character]:
	get: return Game.level.characters.allies
var enemies: Array[Character]:
	get: return Game.level.characters.enemies

var round_number: int = 0
var active_group: StringName = &""

var current_character: Character = null

var acted_allies: Array[Character] = []
var lost_turns: Array[Character] = []
var enemy_turn_index: int = 0

var is_tracking: bool = false


func start_tracking() -> void:
	acted_allies.clear()
	enemy_turn_index = 0
	current_character = null
	is_tracking = true

	_start_round()

func _start_round() -> void:
	round_number += 1

	acted_allies.clear()
	enemy_turn_index = 0
	current_character = null

	round_started.emit(round_number)

	_start_allies_phase()

func _start_allies_phase() -> void:
	active_group = ALLIES_GROUP
	battle_group_started.emit(active_group)
	
	
func start_ally_turn(character: Character) -> bool:
	if not is_tracking:
		return false

	if active_group != ALLIES_GROUP:
		return false

	if character == null:
		return false

	if character not in allies:
		return false

	if character in acted_allies:
		return false

	current_character = character

	if character in lost_turns:
		lost_turns.erase(current_character)
		turn_lost.emit(current_character)
		end_current_turn()
		return false

	turn_started.emit(current_character)
	return true
	
func end_current_turn() -> void:
	if current_character == null:
		return
	
	await Game.level.queue.await_empty()

	var finished_character: Character = current_character
	current_character = null

	turn_ended.emit(finished_character)

	if active_group == ALLIES_GROUP:
		_finish_ally_turn(finished_character)
	elif active_group == ENEMIES_GROUP:
		_finish_enemy_turn()

func lose_turn(character: Character) -> void:
	lost_turns.append(character)

func _finish_ally_turn(character: Character) -> void:
	if character not in acted_allies:
		acted_allies.append(character)

	if acted_allies.size() >= allies.size():
		_start_enemies_phase()
		
func _start_enemies_phase() -> void:
	active_group = ENEMIES_GROUP
	enemy_turn_index = 0

	battle_group_started.emit(active_group)

	_start_next_enemy_turn()
	
func _start_next_enemy_turn() -> void:
	if enemy_turn_index >= enemies.size():
		_start_round()
		return

	current_character = enemies[enemy_turn_index]
	
	if current_character in lost_turns:
		lost_turns.erase(current_character)
		turn_lost.emit(current_character)
		end_current_turn()
	
	else:
		turn_started.emit(current_character)
	
func _finish_enemy_turn() -> void:
	enemy_turn_index += 1
	_start_next_enemy_turn()
