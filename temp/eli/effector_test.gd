extends Node


@onready var user: Character = $Allies/User
@onready var target: Character = $Enemies/Target
@onready var effector: EffectorComponent = $EffectorComponent

func _ready() -> void:
	effector.action_effect_applied.connect(_on_action_effect_applied)

	print("=== EFFECTOR TEST ===")

	_test_damage()
	_test_healing()

func _test_damage() -> void:
	var action := Action.new()
	action.damage = 25

	var before: int = target.health_component.current_health

	effector.apply_action_effects(
		action,
		user,
		target
	)

	var after: int = target.health_component.current_health

	print("Damage test: ", before, " -> ", after)


func _test_healing() -> void:
	target.health_component.take_damage(50)

	var action := Action.new()
	action.healing = 20

	var before: int = target.health_component.current_health

	effector.apply_action_effects(
		action,
		user,
		target
	)

	var after: int = target.health_component.current_health

	print("Healing test: ", before, " -> ", after)

func _on_action_effect_applied(
	action: Action,
	user_character: Character,
	target_character: Character
) -> void:
	print(
		"Action applied: ",
		action,
		" | User: ",
		user_character.name,
		" | Target: ",
		target_character.name
	)
