class_name Character
extends Node2D


const ALLIES_GROUP: StringName = &"allies"
const ENEMIES_GROUP: StringName = &"enemies"

var sprite: Sprite2D:
	get: return $Sprite
var animator_component: CharacterAnimator:
	get: return $Animator
var input_component: CharacterInput:
	get: return $Input
var state_component: CharacterState:
	get: return $State
var actions_component: CharacterActions:
	get: return $Actions
var equipment_component: CharacterEquipment:
	get: return $Equipment
var indicators_component: CharacterIndicators:
	get: return $Indicators
var strategy_component: CharacterStrategy:
	get: return get_node_or_null(^"Strategy") as CharacterStrategy

var actions: Array[Action]:
	get: return actions_component.actions
var equipment: Array[Equipment]:
	get: return equipment_component.equipment

var battle_group: StringName:
	get:
		if is_in_group(ALLIES_GROUP):
			return ALLIES_GROUP

		if is_in_group(ENEMIES_GROUP):
			return ENEMIES_GROUP

		return &""


func _ready() -> void:
	Game.start.connect(_on_combat_start)

	_register_battle_group()

	print("Character: ", name)
	print("Parent: ", get_parent().name)
	print("Battle group: ", battle_group)

	actions_component.character = self
	for action: Action in actions:
		action.owner = self
	
	equipment_component.character = self
	for item: Equipment in equipment:
		item.owner = self
	
	animator_component.character = self
	state_component.character = self
	indicators_component.character = self

	if strategy_component:
		strategy_component.character = self


func _on_combat_start() -> void:
	input_component.selected.connect(Game.level.selector_component.select_character.bind(self))
	input_component.submitted.connect(Game.level.selector_component.submit_target)


func _register_battle_group() -> void:
	var parent_node: Node = get_parent()

	if parent_node == null:
		return

	if parent_node.name == &"Allies":
		add_to_group(ALLIES_GROUP)
	elif parent_node.name == &"Enemies":
		add_to_group(ENEMIES_GROUP)
