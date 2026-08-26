class_name CombatLevel
extends Node


var turn_tracker_component: CombatTurnTracker:
	get: return $TurnTracker
var status_tracker_component: CombatStatusTracker:
	get: return $StatusTracker
var selector_component: CombatSelector:
	get: return $Selector
var effector_component: CombatEffector:
	get: return $Effector
var preview_component: CombatPreview:
	get: return $Preview
var scenery: CombatScenery:
	get: return $Scenery
var camera: CombatCamera:
	get: return $Camera
var ui: CombatUI:
	get: return $UI

var characters_container: Node:
	get: return $Characters
var ally_spawn_points: Node:
	get: return $AllySpawnPoints
var enemy_spawn_points: Node:
	get: return $EnemySpawnPoints

var allies: Array[Character]:
	get: return _get_characters_in_group(&"allies")
var enemies: Array[Character]:
	get: return _get_characters_in_group(&"enemies")
var characters: Array[Character]:
	get: return allies + enemies


func _ready() -> void:
	Game.level = self

	effector_component.action_used.connect(
		_on_action_used
	)

	selector_component.targeting_requested.connect(
		_on_targeting_requested
	)

	selector_component.target_selected.connect(
		_on_target_selected
	)

	print("=== GAME LEVEL TEST ===")
	print("Allies: ", allies.size())
	print("Enemies: ", enemies.size())

	for character: Character in allies:
		print("Ally: ", character.name)

	for character: Character in enemies:
		print("Enemy: ", character.name)

	turn_tracker_component.round_started.connect(
		_on_round_started
	)

	turn_tracker_component.battle_group_started.connect(
		_on_battle_group_started
	)

	turn_tracker_component.turn_started.connect(
		_on_turn_started
	)

	turn_tracker_component.turn_ended.connect(
		_on_turn_ended
	)
	_connect_enemy_strategies()
	turn_tracker_component.start_tracking(allies, enemies)

	Game.start.emit()

func _exit_tree() -> void:
	if Game.level == self:
		Game.level = null

	Game.end.emit()


func _get_characters_in_group(group_name: StringName) -> Array[Character]:
	var result: Array[Character] = []

	for node: Node in get_tree().get_nodes_in_group(group_name):
		if node is Character and characters_container.is_ancestor_of(node):
			result.append(node as Character)

	return result
	
func _connect_enemy_strategies() -> void:
	for enemy: Character in enemies:
		if enemy.strategy_component:
			enemy.strategy_component.action_chosen.connect(_on_enemy_action_chosen)

func _on_action_used(
	action: Action,
	user: Character,
	target: Character
) -> void:
	Debug.info(
		"%s used an action on %s." % [
			user.name,
			target.name
		]
	)
	
	
func _on_targeting_requested(
	action: Action,
	user: Character
) -> void:
	Debug.info(
		"%s is selecting a target." % user.name
	)


func _on_target_selected(
	action: Action,
	user: Character,
	target: Character
) -> void:
	effector_component.apply(
		action,
		user,
		target
	)
	
func _on_round_started(round_number: int) -> void:
	print("ROUND ", round_number)


func _on_battle_group_started(group_name: StringName) -> void:
	print("PHASE: ", group_name)


func _on_turn_started(character: Character) -> void:
	print("TURN STARTED: ", character.name)
	if character.strategy_component:
		character.strategy_component.take_turn()

func _on_turn_ended(character: Character) -> void:
	print("TURN ENDED: ", character.name)

func _on_enemy_action_chosen(action: Action, user: Character, target: Character) -> void:
	if action != null and target != null:
		effector_component.apply(action, user, target)
	turn_tracker_component.end_current_turn()
