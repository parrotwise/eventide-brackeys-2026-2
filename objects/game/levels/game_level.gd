class_name GameLevel
extends Node


var effector_component: EffectorComponent:
	get:
		return $EffectorComponent


var preview_component: Node:
	get:
		return $PreviewComponent


var selector_component: Node:
	get:
		return $SelectorComponent


var status_effect_tracker: Node:
	get:
		return $StatusEffectTracker


var turn_tracker_component: TurnTrackerComponent:
	get:
		return $TurnTrackerComponent

var scenery: Node:
	get:
		return $Scenery


var characters_container: Node:
	get:
		return $Characters


var ally_spawn_points: Node:
	get:
		return $AllySpawnPoints


var enemy_spawn_points: Node:
	get:
		return $EnemySpawnPoints


var ui: CanvasItem:
	get:
		return $UI


var allies: Array[Character]:
	get:
		return _get_characters_in_group(&"allies")


var enemies: Array[Character]:
	get:
		return _get_characters_in_group(&"enemies")


var characters: Array[Character]:
	get:
		var result: Array[Character] = []
		result.append_array(allies)
		result.append_array(enemies)
		return result


func _ready() -> void:
	Game.level = self

	Game.start.emit()

	effector_component.action_effect_applied.connect(
		_on_action_effect_applied
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

	turn_tracker_component.start_tracking(allies, enemies)

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


func _on_action_effect_applied(
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
	effector_component.apply_action_effects(
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


func _on_turn_ended(character: Character) -> void:
	print("TURN ENDED: ", character.name)
