class_name Character
extends Node2D


const ALLIES_GROUP: StringName = &"allies"
const ENEMIES_GROUP: StringName = &"enemies"

var actor: Actor:
	get: return $Actor
var sprite: Sprite2D:
	get: return $Sprite
var label: RichTextLabel:
	get: return $Name
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
		if Game.level is not CombatLevel:
			return ""
		
		if self in Game.level.characters.allies:
			return ALLIES_GROUP

		if self in Game.level.characters.enemies:
			return ENEMIES_GROUP

		return &""


func _ready() -> void:
	Game.start.connect(_on_combat_start)

	animator_component.character = self
	input_component.character = self
	state_component.character = self
	actions_component.character = self
	equipment_component.character = self
	indicators_component.character = self

	if strategy_component:
		strategy_component.character = self
	
	equipment_component.get_inventory()


func _process(delta: float) -> void:
	if Game.level is not CombatLevel:
		return
	
	position = lerp(
		position, Game.level.characters.target_position(self),
		exp(-delta / Game.level.positioning_acceleration)
	)


func _on_combat_start() -> void:
	input_component.selected.connect(Game.level.selector_component.select_character.bind(self))
	input_component.submitted.connect(func(_c): Game.level.selector_component.submit_target())
	
	# Change orientation based on team.
	if battle_group == ALLIES_GROUP:
		actor.scale = Vector2(1.0, 1.0)
	else:
		actor.scale = Vector2(-1.0, 1.0)
