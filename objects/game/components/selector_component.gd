class_name SelectorComponent
extends Node


signal targeting_requested(
	action: Action,
	user: Character
)

signal target_selected(
	action: Action,
	user: Character,
	target: Character
)


var current_action: Action = null
var current_user: Character = null
var is_targeting: bool = false


func request_targeting(
	action: Action,
	user: Character
) -> void:
	if action == null or user == null:
		return

	current_action = action
	current_user = user
	is_targeting = true

	targeting_requested.emit(
		current_action,
		current_user
	)


func select_target(target: Character) -> void:
	if not is_targeting:
		return

	if current_action == null or current_user == null:
		return

	if target == null:
		return

	target_selected.emit(
		current_action,
		current_user,
		target
	)

	_clear_targeting()


func cancel_targeting() -> void:
	_clear_targeting()


func _clear_targeting() -> void:
	current_action = null
	current_user = null
	is_targeting = false
