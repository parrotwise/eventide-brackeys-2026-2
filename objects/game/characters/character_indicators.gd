class_name CharacterIndicators
extends Control


@export_group("Status Effects")

@export var symbol_icon_scene: PackedScene
@onready var _sloshed_particles: GPUParticles2D = $"../BubbleEmitter"

@onready var _health_bar: Node = $HealthBar

@onready var _status_texture: TextureRect = $StatusEffectIndicator/TextureRect
@onready var _status_label: Label = $StatusEffectIndicator/VBoxContainer/Label
@onready var _status_symbols: Container = $StatusEffectIndicator/VBoxContainer/StatusEffectSymbols


var character: Character:
	set(value):
		character = value
		_on_character_set()

var _status_symbol_nodes: Dictionary = {}

func _on_character_set() -> void:
	if character == null:
		return

	var state: CharacterState = character.state_component
	state.health_changed.connect(update_health_bar)
	state.status_applied.connect(_on_status_applied)
	state.status_removed.connect(_on_status_removed)
	
	update_health_bar(state.current_health, state.max_health)

	for status: Status in state.active_statuses:
		_add_status_symbol(status)
	_update_sloshed_indicator()


func update_health_bar(current_health: int, max_health: int) -> void:
	_health_bar.set_health(current_health, max_health)
	
func _on_status_applied(status: Status) -> void:
	_add_status_symbol(status)
	_update_sloshed_indicator()


func _on_status_removed(status: Status) -> void:
	_remove_status_symbol(status)
	_update_sloshed_indicator()

func _add_status_symbol(status: Status) -> void:
	if status in _status_symbol_nodes or symbol_icon_scene == null:
		return

	var symbol: Control = symbol_icon_scene.instantiate()
	var icon_rect: TextureRect = symbol.get_node_or_null(^"TextureRect") as TextureRect
	if icon_rect:
		icon_rect.texture = status.icon

	_status_symbols.add_child(symbol)
	_status_symbol_nodes[status] = symbol


func _remove_status_symbol(status: Status) -> void:
	var symbol: Node = _status_symbol_nodes.get(status)
	if symbol == null:
		return

	symbol.queue_free()
	_status_symbol_nodes.erase(status)
	
func _update_sloshed_indicator() -> void:
	var is_sloshed := false

	for status: Status in character.state_component.active_statuses:
		if status.name == "Sloshed":
			is_sloshed = true
			break
			
	print("Is sloshed: ", is_sloshed)

	_sloshed_particles.emitting = is_sloshed
