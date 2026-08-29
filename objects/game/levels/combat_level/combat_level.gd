class_name CombatLevel
extends Node


@export_range(0.005, 0.15, 0.001) var positioning_acceleration: float = 0.007

var queue: CombatQueue:
	get: return $Queue
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
var characters: CombatCharacters:
	get: return $Characters
var ground_objects: CombatGroundObjects:
	get: return $GroundObjects
var ui: CombatUI:
	get: return $UI

var ally_spawn_points: Node:
	get: return $AllySpawnPoints
var enemy_spawn_points: Node:
	get: return $EnemySpawnPoints


func _ready() -> void:
	Game.level = self

	effector_component.action_used.connect(
		_on_action_used
	)

	effector_component.action_missed.connect(
		_on_action_missed
	)

	effector_component.action_finished.connect(
		_on_action_finished
	)

	status_tracker_component.status_applied.connect(
		_on_status_applied
	)

	status_tracker_component.status_removed.connect(
		_on_status_removed
	)

	status_tracker_component.trigger_fired.connect(
		_on_trigger_fired
	)

	selector_component.action_selected.connect(
		_on_action_selected
	)

	selector_component.target_selected.connect(
		_on_target_selected
	)
	
	selector_component.ally_selected.connect(
		_on_ally_selected
	)

	selector_component.target_submitted.connect(
		_on_target_submitted
	)

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
	turn_tracker_component.start_tracking()

	Game.start.emit()


func _exit_tree() -> void:
	if Game.level == self:
		Game.level = null

	Game.end.emit()


func _connect_enemy_strategies() -> void:
	for enemy: Character in characters.enemies:
		if enemy.strategy_component:
			enemy.strategy_component.action_chosen.connect(_on_enemy_action_chosen)


func _on_action_used(
	action: Action,
	user: Character,
	target: Character
) -> void:
	Debug.debug(
		"%s used %s on %s." % [
			user.name,
			action.name,
			target.name
		]
	)
	user.actor.do_action_as_user(action, target)
	# target.actor.do_action_as_target(action)

func _on_action_missed(
	action: Action,
	_user: Character,
	_target: Character
) -> void:
	Debug.debug(
		"%s missed!" % [
			action.name,
		]
	)
	

func _on_action_finished(
	action: Action,
	user: Character,
	target: Character
) -> void:
	Debug.debug(
		"%s finished using %s on %s." % [
			user.name,
			action.name,
			target.name
		]
	)
	selector_component.cancel_action()
	turn_tracker_component.end_current_turn()
	
	
func _on_action_selected(action: Action) -> void:
	Debug.debug(
		"%s has selected %s, targeting requested." % [
			selector_component.current_user.name,
			action.name,
		]
	)


func _on_status_applied(status: Status) -> void:
	Debug.debug(
		"%s gained %s." % [
			status.owner.name,
			status.name
		]
	)


func _on_status_removed(status: Status) -> void:
	Debug.debug(
		"%s lost %s." % [
			status.owner.name,
			status.name
		]
	)


func _on_trigger_fired(trigger: Trigger) -> void:
	Debug.debug(
		"Triggered effect fired by %s!" % [
			trigger.effect.source.name
		]
	)


func _on_target_selected(
	action: Action,
	user: Character,
	target: Character
) -> void:
	Debug.debug(
		"%s has selected %s as the target for %s." % [
			user.name,
			target.name,
			action.name,
		]
	)

	for other: Character in characters.all:
		other.indicators_component.hide_target_indicator()
	target.indicators_component.show_target_indicator()

	# TODO: preview_component.preview(action, user, target)


func _on_target_submitted(
	action: Action,
	user: Character,
	target: Character
) -> void:
	selector_component.pause()


func _on_ally_selected(ally: Character):
	ui.set_action_buttons(ally)

	for other: Character in characters.allies:
		other.indicators_component.hide_selection_indicator()
	ally.indicators_component.show_selection_indicator()
	
	turn_tracker_component.start_ally_turn(ally)


func _on_round_started(round_number: int) -> void:
	Debug.debug("-- ROUND %d --" % round_number)


func _on_battle_group_started(group_name: StringName) -> void:
	Debug.debug("-- %s phase!" % group_name)
	if group_name == turn_tracker_component.ALLIES_GROUP:
		selector_component.select_ally(characters.ally_melee, false)


func _on_turn_started(character: Character) -> void:
	Debug.debug("%s's turn started." % character.name)
	if character in characters.allies:
		selector_component.resume()
	if character.strategy_component:
		character.strategy_component.take_turn()


func _on_turn_ended(character: Character) -> void:
	Debug.debug("%s's turn ended." % character.name)

	if character not in characters.allies:
		return
	
	if characters.free_allies:
		selector_component.cycle_through_allies(Enums.Direction.RIGHT, false)
	else:
		selector_component.reset()
		ui.reset_action_panel()


func _on_enemy_action_chosen(action: Action, user: Character, target: Character) -> void:
	if action != null and target != null:
		effector_component.apply(action, user, target)
