class_name Character
extends Node2D


const ALLIES_GROUP: StringName = &"allies"
const ENEMIES_GROUP: StringName = &"enemies"


var health_component: HealthComponent:
	get:
		return $HealthComponent


var actions_component: ActionsComponent:
	get:
		return $ActionsComponent


var battle_group: StringName:
	get:
		if is_in_group(ALLIES_GROUP):
			return ALLIES_GROUP

		if is_in_group(ENEMIES_GROUP):
			return ENEMIES_GROUP

		return &""


func _ready() -> void:
	health_component.character = self
	_register_battle_group()


func _register_battle_group() -> void:
	var parent_node: Node = get_parent()

	if parent_node == null:
		return

	if parent_node.name == &"Allies":
		add_to_group(ALLIES_GROUP)
	elif parent_node.name == &"Enemies":
		add_to_group(ENEMIES_GROUP)
