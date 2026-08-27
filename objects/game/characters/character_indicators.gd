class_name CharacterIndicators
extends Control


@export_group("Status Effects")

@export var symbol_icon_scene: PackedScene

@onready var _health_bar: Node = $HealthBar

@onready var _status_texture: TextureRect = $StatusEffectIndicator/TextureRect
@onready var _status_label: Label = $StatusEffectIndicator/VBoxContainer/Label
@onready var _status_symbols: Container = $StatusEffectIndicator/VBoxContainer/StatusEffectSymbols


var character: Character:
	set(value):
		character = value
		_on_character_set()

var _status_symbol_nodes: Dictionary = {}
var _featured_status: Status


func _on_character_set() -> void:
	if character == null:
		return

	var state: CharacterState = character.state_component
	state.health_changed.connect(_on_health_changed)
	state.status_applied.connect(_on_status_applied)
	state.status_removed.connect(_on_status_removed)
	state.knockout.connect(_on_knockout)

	update_health_bar(state.current_health, state.max_health)

	for status: Status in state.active_statuses:
		_add_status_symbol(status)
	_set_featured_status(state.active_statuses.back() if not state.active_statuses.is_empty() else null)


func update_health_bar(current_health: int, max_health: int) -> void:
	if _health_bar.has_method(&"set_health"):
		_health_bar.set_health(current_health, max_health)
	else:
		push_warning("HealthBar has no set_health(current_health, max_health) method.")


func _on_health_changed(current_health: int, max_health: int) -> void:
	update_health_bar(current_health, max_health)


func _on_status_applied(status: Status) -> void:
	_add_status_symbol(status)
	_set_featured_status(status)


func _on_status_removed(status: Status) -> void:
	_remove_status_symbol(status)

	if status == _featured_status:
		var remaining: Array[Status] = character.state_component.active_statuses
		_set_featured_status(remaining.back() if not remaining.is_empty() else null)


func _on_knockout() -> void:
	pass


func _add_status_symbol(status: Status) -> void:
	if status in _status_symbol_nodes or symbol_icon_scene == null:
		return

	var symbol: Control = symbol_icon_scene.instantiate()
	var icon_rect: TextureRect = symbol.get_node_or_null(^"TextureRect") as TextureRect
	if icon_rect:
		icon_rect.texture = status.icon

	symbol.mouse_entered.connect(_set_featured_status.bind(status))
	symbol.mouse_exited.connect(_on_symbol_mouse_exited)

	_status_symbols.add_child(symbol)
	_status_symbol_nodes[status] = symbol


func _remove_status_symbol(status: Status) -> void:
	var symbol: Node = _status_symbol_nodes.get(status)
	if symbol == null:
		return

	symbol.queue_free()
	_status_symbol_nodes.erase(status)


func _on_symbol_mouse_exited() -> void:
	var remaining: Array[Status] = character.state_component.active_statuses
	_set_featured_status(remaining.back() if not remaining.is_empty() else null)


func _set_featured_status(status: Status) -> void:
	_featured_status = status

	var has_status: bool = status != null
	_status_texture.visible = has_status
	_status_label.visible = has_status

	if has_status:
		_status_label.text = status.name
