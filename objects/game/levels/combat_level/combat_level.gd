class_name CombatLevel
extends Node


@export_range(0.005, 0.15, 0.001) var positioning_acceleration: float = 0.007

var queue: CombatQueue:
	get: return $Queue
var turn_tracker: CombatTurnTracker:
	get: return $TurnTracker
var status_tracker: CombatStatusTracker:
	get: return $StatusTracker
var selector: CombatSelector:
	get: return $Selector
var effector: CombatEffector:
	get: return $Effector
var preview: CombatPreview:
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
	Game.combat = self

	Game.combat_end.connect(_on_combat_end)

	effector.action_used.connect(
		_on_action_used
	)

	effector.action_missed.connect(
		_on_action_missed
	)

	effector.action_finished.connect(
		_on_action_finished
	)

	status_tracker.status_applied.connect(
		_on_status_applied
	)

	status_tracker.status_removed.connect(
		_on_status_removed
	)

	status_tracker.trigger_fired.connect(
		_on_trigger_fired
	)

	selector.action_selected.connect(
		_on_action_selected
	)

	selector.target_selected.connect(
		_on_target_selected
	)

	selector.target_cancelled.connect(
		_on_target_cancelled
	)
	
	selector.ally_selected.connect(
		_on_ally_selected
	)

	selector.target_submitted.connect(
		_on_target_submitted
	)

	turn_tracker.round_started.connect(
		_on_round_started
	)

	turn_tracker.battle_group_started.connect(
		_on_battle_group_started
	)

	turn_tracker.turn_started.connect(
		_on_turn_started
	)

	turn_tracker.turn_lost.connect(
		_on_turn_lost
	)

	turn_tracker.turn_ended.connect(
		_on_turn_ended
	)

	if Game.stage == Game.Stage.LOADOUT1:
		characters.mutiny()
	else:
		characters.spawn()

	for character: Character in characters.all:
		character.state.health_changed.connect(_on_health_changed.bind(character))
		character.state.knockout.connect(_on_knocked_out.bind(character))
	
	for enemy: Character in characters.enemies:
		if enemy.strategy:
			enemy.strategy.action_chosen.connect(_on_enemy_action_chosen)
	
	turn_tracker.start_tracking()
	
	Game.combat_start.emit()


func _on_health_changed(previous_health: int, current_health: int, character: Character) -> void:
	Debug.debug(
		"%s's health changed from %d to %d." % [
			tr(character.name),
			previous_health,
			current_health,
		]
	)


func _on_knocked_out(character: Character) -> void:
	Debug.debug(
		"%s was knocked out!" % [
			tr(character.name),
		]
	)


func _exit_tree() -> void:
	if Game.combat == self:
		Game.combat = null


func _on_action_used(
	action: Action,
	user: Character,
	target: Character
) -> void:
	Debug.debug(
		"%s used %s on %s." % [
			tr(user.name),
			tr(action.name),
			tr(target.name)
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
			tr(action.name),
		]
	)
	

func _on_action_finished(action: Action) -> void:
	Debug.debug("%s finished using %s." % [tr(action.owner.name), tr(action.name)])

	if turn_tracker.current_character not in characters.enemies:
		selector.cancel_action()

	if action.free_action and action.owner.actions.usable_actions:
		selector.resume()
	else:
		turn_tracker.end_current_turn()
	
	
	
func _on_action_selected(action: Action) -> void:
	Debug.debug(
		"%s has selected %s, targeting requested." % [
			tr(selector.current_user.name),
			tr(action.name),
		]
	)
	if action.name in [
		&"ACTION_ATTACK_BC_NAME",
		&"ACTION_ATTACK_BHC_NAME",
		&"ACTION_ATTACK_EC_NAME",
		&"ACTION_ATTACK_NC_NAME",
		&"ACTION_ATTACK_PC_NAME",
		&"ACTION_ATTACK_RC_NAME",
		&"ACTION_ATTACK_SC_NAME",
	]:
		Game.pointer.switch_to(Enums.PointerType.ATTACK)
	elif action.name == &"ACTION_ATTACK_GC_NAME":
		Game.pointer.switch_to(Enums.PointerType.SLOP)
	elif action.name == &"ACTION_REPOSITION_NAME":
		Game.pointer.switch_to(Enums.PointerType.SWAP)
	else:
		Game.pointer.switch_to(Enums.PointerType.TARGET)


func _on_status_applied(status: Status) -> void:
	Debug.debug(
		"%s gained %s." % [
			tr(status.owner.name),
			tr(status.name)
		]
	)


func _on_status_removed(status: Status) -> void:
	Debug.debug(
		"%s lost %s." % [
			tr(status.owner.name),
			tr(status.name)
		]
	)


func _on_trigger_fired(trigger: Trigger) -> void:
	Debug.debug(
		"Triggered effect fired by %s!" % [
			trigger.effect.source.name
		]
	)
	if not is_instance_valid(trigger.effect.source.owner):
		return
	
	trigger.effect.source.owner.actor.do_trigger_as_user(trigger)


func _on_target_selected(
	action: Action,
	user: Character,
	target: Character
) -> void:
	Debug.debug(
		"%s has selected %s as the target for %s." % [
			tr(user.name),
			tr(target.name),
			tr(action.name),
		]
	)

	for other: Character in characters.all:
		other.indicators.hide_target_indicator()
	target.indicators.show_target_indicator()

	preview.preview_action(action, user, target)


func _on_target_cancelled(
	_action: Action,
	_user: Character,
	target: Character
) -> void:
	if is_instance_valid(target):
		target.indicators.hide_target_indicator()
	
	preview.hide_previews()


func _on_target_submitted(
	_action: Action,
	_user: Character,
	_target: Character
) -> void:
	selector.pause()
	preview.hide_previews()


func _on_ally_selected(ally: Character):
	ui.setup_bottom_bar(ally)

	for other: Character in characters.allies:
		other.indicators.hide_selection_indicator()
	ally.indicators.show_selection_indicator()
	
	await turn_tracker.start_ally_turn(ally)


func _on_round_started(round_number: int) -> void:
	Debug.debug("-- ROUND %d --" % round_number)


func _on_battle_group_started(group_name: StringName) -> void:
	Debug.debug("-- %s phase!" % group_name)
	if group_name == turn_tracker.ALLIES_GROUP:
		selector.reset()


func _on_turn_started(character: Character) -> void:
	Debug.debug("%s's turn started." % tr(character.name))
	if character in characters.allies:
		selector.resume()
	if character in Game.enemies:
		character.strategy.take_turn()


func _on_turn_lost(character: Character) -> void:
	Debug.debug("%s's turn was lost!" % tr(character.name))


func _on_turn_ended(character: Character) -> void:
	Debug.debug("%s's turn ended." % tr(character.name))

	if character not in characters.allies:
		return
	
	if characters.free_allies:
		selector.cycle_through_allies(Enums.Direction.RIGHT, false)
	else:
		selector.reset()
		ui.reset_bottom_bar()


func _on_enemy_action_chosen(action: Action, user: Character, target: Character) -> void:
	if action != null and target != null:
		action.use(user, target)


func _on_combat_end() -> void:
	queue.clear()
	selector.pause()

	for character: Character in characters.all:
		character.strategy.pause()

	await get_tree().create_timer(3).timeout
	
	for character: Character in characters.all:
		character.get_parent().remove_child(character)
	
	if not Game.allies:
		TransitionLayer.transition_simple_fade(
			TransitionLayer.cutscene_combat_defeat
		)
	elif Game.stage == Game.Stage.COMBAT1 and Game.allies.size() >= 2:
		TransitionLayer.transition_simple_fade(
			TransitionLayer.cutscene_combat_victory
		)
	else:
		TransitionLayer.transition_simple_fade(
			TransitionLayer.cutscene_final_betrayal
		)
