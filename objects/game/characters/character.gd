class_name Character
extends Node2D


const ALLIES_GROUP: StringName = &"allies"
const ENEMIES_GROUP: StringName = &"enemies"

@export var id: StringName

var actor: Actor:
	get: return $Actor
var sprite: Sprite2D:
	get: return $Sprite
var label: RichTextLabel:
	get: return $Name
var animator: CharacterAnimator:
	get: return $Animator
var input: CharacterInput:
	get: return $Input
var state: CharacterState:
	get: return $State
var actions: CharacterActions:
	get: return $Actions
var equipment: CharacterEquipment:
	get: return $Equipment
var indicators: CharacterIndicators:
	get: return $Indicators
var strategy: CharacterStrategy:
	get: return get_node_or_null(^"Strategy") as CharacterStrategy

var all_actions: Array[Action]:
	get: return actions.actions
var all_equipment: Array[Equipment]:
	get: return equipment.equipment

var battle_group: StringName:
	get:
		if Game.combat is not CombatLevel:
			return ""
		
		if self in Game.combat.characters.allies:
			return ALLIES_GROUP

		if self in Game.combat.characters.enemies:
			return ENEMIES_GROUP

		return &""


func _ready() -> void:
	name = id
	
	Game.combat_start.connect(_on_combat_start)

	animator.character = self
	input.character = self
	state.character = self
	actions.character = self
	equipment.character = self
	indicators.character = self

	if strategy:
		strategy.character = self


func _process(delta: float) -> void:
	if Game.combat is not CombatLevel:
		return
	
	position = lerp(
		position, Game.combat.characters.target_position(self),
		exp(-delta / Game.combat.positioning_acceleration)
	)


func _on_combat_start() -> void:
	input.selected.connect(Game.combat.selector.select_character.bind(self))
	input.deselected.connect(Game.combat.selector.deselect_character.bind(self))
	input.submitted.connect(func(_c): Game.combat.selector.submit_target())
	
	# Change orientation based on team.
	if battle_group == ALLIES_GROUP:
		actor.scale = Vector2(1.0, 1.0)
	else:
		actor.scale = Vector2(-1.0, 1.0)
