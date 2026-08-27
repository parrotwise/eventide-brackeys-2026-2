class_name CharacterIndicators
extends Control


# @export_group("Status Effects")
@export var status_icon_template: PackedScene

var stun_icon: Sprite2D:
	get: return $StunIcon
var health_bar: Node:
	get: return $HealthBar
var status_icons: HBoxContainer:
	get: return $StatusEffectIndicator/VBoxContainer/StatusIcons
var sloshed_particles: GPUParticles2D:
	get: return $BubbleEmitter
var poison_particles: GPUParticles2D:
	get: return $GreenDropEmitter

var character: Character:
	set(value):
		character = value
		_on_character_set()

var _status_icons: Dictionary = {}


func _on_character_set() -> void:
	if character == null:
		return

	var state: CharacterState = character.state_component
	state.health_changed.connect(_update_health_bar)
	state.status_applied.connect(_on_status_applied)
	state.status_removed.connect(_on_status_removed)
	
	_update_health_bar(state.current_health, state.max_health)
	_update_status_indicators()

	for status: Status in state.active_statuses:
		_add_status_icon(status)


func _update_health_bar(current_health: int, max_health: int) -> void:
	health_bar.set_health(current_health, max_health)


func _on_status_applied(status: Status) -> void:
	_add_status_icon(status)
	_update_status_indicators()


func _on_status_removed(status: Status) -> void:
	_remove_status_icon(status)
	_update_status_indicators()


func _update_status_indicators() -> void:
	stun_icon.visible = character.state_component.active_statuses.any(
		func(status): return status.name == "Stunned"
	)
	sloshed_particles.emitting = character.state_component.active_statuses.any(
		func(status): return status.name == "Sloshed"
	)
	poison_particles.emitting = character.state_component.active_statuses.any(
		func(status): return status.name == "Poisoned"
	)


func _add_status_icon(status: Status) -> void:
	if status in _status_icons or status_icon_template == null:
		return

	var symbol: Control = status_icon_template.instantiate()
	var icon_rect: TextureRect = symbol.get_node_or_null(^"TextureRect") as TextureRect
	if icon_rect:
		icon_rect.texture = status.icon

	status_icons.add_child(symbol)
	_status_icons[status] = symbol


func _remove_status_icon(status: Status) -> void:
	var status_icon: Node = _status_icons.get(status)
	if status_icon == null:
		return

	status_icon.queue_free()
	_status_icons.erase(status)
