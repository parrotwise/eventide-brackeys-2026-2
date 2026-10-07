class_name Actor
extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target: Character = null
var in_stance: bool = false


func do_action_as_user(action: Action, _target: Character):
	# Recall target
	target = _target
	
	# Basic attack
	if 'ACTION_ATTACK_' in action.name:
		basic_attack()
	
	# The Wringer's skill
	if action.name == &"ACTION_SKILL_BC_NAME":
		in_stance = true
		enter_stance()
	
	# Other character skills
	elif 'ACTION_SKILL_' in action.name:
		special()
	
	if action.name == &"ACTION_CRUNCH_PEANUTS_NAME":
		heal()
	# basic_attack()


func do_trigger_as_user(trigger: Trigger):
	var triggering_source: Variant = trigger.effect.source
	
	# Basic attack
	if triggering_source.name == &"STATUS_JAW_CRUNCHER_NAME":
		exit_stance()


func fire_effect(effect: Effect) -> void:
	target = effect.target
	
	if effect.name == &"ACTION_SKILL_BC_NAME":
		special()


# No longer used.
func do_action_as_target(action: Action):
	if 'ACTION_ATTACK_' in action.name:
		pass
	await get_tree().create_timer(0.6).timeout
	hurt()


# Animation functions!
func hurt_target() -> void:
	if not is_instance_valid(target):
		return
	
	target.actor.hurt()


func heal_target() -> void:
	if not is_instance_valid(target):
		return
	
	target.actor.heal()


func hurt_random_target() -> void:
	var random_target: Character = Game.combat.effector.last_random_target
	if random_target == null: return
	random_target.actor.hurt()


func launch_ground_object() -> void:
	Game.combat.ground_objects.launch(global_position + Vector2(0.0, -400.0))


func basic_attack() -> void:
	if animation_player.has_animation(&"basic_attack"):
		animation_player.play(&"basic_attack")
	if animation_player.has_animation(&"idle"):
		animation_player.queue(&"idle")


func hurt() -> void:
	if animation_player.has_animation(&"hurt"):
		animation_player.play(&"hurt")
	if in_stance:
		if animation_player.has_animation(&"stance"):
			animation_player.queue(&"stance")
	else:
		if animation_player.has_animation(&"idle"):
			animation_player.queue(&"idle")


func special() -> void:
	if animation_player.has_animation(&"special"):
		animation_player.play(&"special")
	if animation_player.has_animation(&"idle"):
		animation_player.queue(&"idle")
	in_stance = false


func enter_stance() -> void:
	if animation_player.has_animation(&"enter_stance"):
		animation_player.play(&"enter_stance")
	if animation_player.has_animation(&"stance"):
		animation_player.queue(&"stance")


func exit_stance() -> void:
	if animation_player.has_animation(&"exit_stance"):
		animation_player.play(&"exit_stance")
	if animation_player.has_animation(&"idle"):
		animation_player.queue(&"idle")


func dead() -> void:
	pass


func heal() -> void:
	if not is_inside_tree():
		return
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(0.0, -100.0), 0.15)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", Vector2(0.0, 0.0), 0.25)


func _ready() -> void:
	if animation_player.has_animation(&"idle"):
		animation_player.play(&"idle")

# Possible implementaitons in the future:
# enter_stance
# throw_projectile
# set_status
