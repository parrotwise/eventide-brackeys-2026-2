class_name CharacterIndicators
extends Control


# @export_group("Status Effects")
@export var status_icon_template: PackedScene

var stun_icon: Sprite2D:
	get: return $StunIcon
var health_bar: HealthBar:
	get: return $HealthBar
var status_bar: StatusBar:
	get: return $StatusBar
var preview_bar: PreviewBar:
	get: return $PreviewBar
var sloshed_particles: GPUParticles2D:
	get: return $BubbleEmitter
var poison_particles: GPUParticles2D:
	get: return $GreenDropEmitter
var selection_indicator: Sprite2D:
	get: return $SelectionIndicator
var target_indicator: Sprite2D:
	get: return $TargetIndicator

var character: Character:
	set(value):
		character = value
		_on_character_set()


func _ready() -> void:
	Game.start.connect(_on_combat_start)


func preview_effect(effect: Effect) -> void:
	preview_bar.add_icons_for(effect)


func hide_previews() -> void:
	preview_bar.clear_icons()


func add_status_icon(status: Status) -> void:
	status_bar.add_icon(status)


func remove_status_icon(status: Status) -> void:
	status_bar.remove_icon(status)


func hide_target_indicator() -> void:
	target_indicator.hide()


func show_target_indicator() -> void:
	target_indicator.show()


func hide_selection_indicator() -> void:
	selection_indicator.hide()


func show_selection_indicator() -> void:
	selection_indicator.show()


func _on_combat_start() -> void:
	Game.combat.effector.action_submitted.connect(_on_action_submitted)


func _on_action_submitted(_action: Action, _user: Character, _target: Character) -> void:
	hide_selection_indicator()
	hide_target_indicator()


func _on_character_set() -> void:
	if character == null:
		return

	var state: CharacterState = character.state
	state.health_changed.connect(_update_health_bar)
	state.status_applied.connect(add_status_icon)
	state.status_removed.connect(remove_status_icon)
	
	_update_health_bar(state.current_health, state.max_health)
	_update_status_indicators()


func _update_health_bar(_previous_health: int, current_health: int) -> void:
	health_bar.set_health(current_health, character.state.max_health)


func _update_status_indicators() -> void:
	stun_icon.visible = character.state.active_statuses.any(
		func(status): return status.name == "Stunned"
	)
	sloshed_particles.emitting = character.state.active_statuses.any(
		func(status): return status.name == "Sloshed"
	)
	poison_particles.emitting = character.state.active_statuses.any(
		func(status): return status.name == "Poisoned"
	)

