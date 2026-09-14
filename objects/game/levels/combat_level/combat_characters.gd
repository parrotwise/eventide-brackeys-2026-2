class_name CombatCharacters
extends Node

@export var character_crewmembers: Array[PackedScene]
@export var strategy_scene: PackedScene

signal character_removed(character: Character)
signal characters_repositioned(char1: Character, char2: Character)


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


func _ready() -> void:
	first_round_crew_select()



func _process(_delta: float) -> void:
	for character: Character in all:
		character.sprite.flip_h = character in enemies
		character.input_component.set_flip(character in enemies)


func remove(character: Character) -> void:
	for status: Status in character.state_component.active_statuses.duplicate():
		character.state_component.remove_status(status)
	
	character_removed.emit(character)
	character.queue_free()


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


func get_ahead_of(character: Character, in_group: bool = false) -> Character:
	return _get_character_at_offset(-1, character, in_group)


func get_all_ahead_of(character: Character) -> Array[Character]:
	var frendos: Array[Character] = allies if character in allies else enemies
	return Array(
		frendos.filter(func(f): return index_of(f) < index_of(character)),
		TYPE_OBJECT, &'Node2D', Character
	)


func get_behind(character: Character, in_group: bool = false) -> Character:
	return _get_character_at_offset(+1, character, in_group)


func get_all_behind(character: Character) -> Array[Character]:
	var frendos: Array[Character] = allies if character in allies else enemies
	return Array(
		frendos.filter(func(f): return index_of(f) > index_of(character)),
		TYPE_OBJECT, &'Node2D', Character
	)


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

	if index1 > index2:
		while index_of(char1) != index2:
			move_forward(char1)
	elif index1 < index2:
		while index_of(char2) != index1:
			move_forward(char2)


func move_forward(character: Character) -> void:
	_move_by(-1, character)


func move_backward(character: Character) -> void:
	_move_by(+1, character)


func _get_character_at_offset(offset: int, character: Character, in_group: bool = false) -> Character:
	if character not in all:
		return null
	
	if in_group:
		pass
	
	elif character == ally_melee and offset < 0:
		# Hacky solution, only works because our largest splash radius is 1
		return enemy_melee if offset == -1 else null
	
	elif character == enemy_melee and offset < 0:
		# Hacky solution, only works because our largest splash radius is 1
		return ally_melee if offset == -1 else null
	
	var frendos: Array[Character] = allies if character in allies else enemies
	var index: int = frendos.find(character)
	var offset_index: int = index + offset

	if offset_index >= 0 and offset_index < frendos.size():
		return frendos[offset_index]
	
	return null


func _move_by(steps: int, character: Character) -> void:
	if character not in all:
		return
	
	if not character.state_component.can_move:
		return
	
	var frendos: Array[Character] = allies if character in allies else enemies
	var current_index: int = frendos.find(character)
	var new_index: int = current_index + steps
	
	if new_index < 0 or new_index >= frendos.size():
		return
	
	if not frendos[new_index].state_component.can_move:
		return
	
	if steps > 0:
		for i: int in range(current_index, new_index):
			characters_repositioned.emit(frendos[i], frendos[i + 1])
	elif steps < 0:
		for i: int in range(new_index, current_index):
			characters_repositioned.emit(frendos[i], frendos[i + 1])

	character.get_parent().move_child(character, new_index)



func first_round_crew_select() -> void:
	character_crewmembers.shuffle()
	for idx in len(character_crewmembers):
		var character: Character = character_crewmembers[idx].instantiate()
		character.name = [
			"AllyFront",
			"AllyCenterFront",
			"AllyCenterRear",
			"AllyRear",
			"EnemyFront",
			"EnemyCenterFront",
			"EnemyCenterRear",
			"EnemyRear",
		][idx]
		
		if idx < 4:
			$Allies.add_child(character)
		else:
			character.add_child(strategy_scene.instantiate())
			$Enemies.add_child(character)
	
	for character in allies: character.position = target_position(character)
	for character in enemies: character.position = target_position(character)
