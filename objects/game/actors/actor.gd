class_name Actor extends Node2D
# Used to control a character visually

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target: Character = null
var in_stance: bool = false

func do_action_as_user(action: Action, _target: Character):
	# Recall target
	target = _target
	
	# Basic attack
	if action.name in [
		&"Basic Attack",
		&"Throw Hardtack",
		&"Sling Slop",
	]:
		basic_attack()
	
	# Special abilities
	if action.name in [
		&"Roll the Pot",
		&"Powder Satchel",
		&"Two for One",
		&"Keelhaul Tug",
		&"Laser-Focused",
		&"Peanut Scatter",
		&"Mug Toss",
	]:
		special()
	
	if action.name == &"Jaw Cruncher":
		in_stance = true
		enter_stance()
	
	if action.name == &"Pick Up & Crunch":
		heal()
	# basic_attack()


func do_trigger_as_user(trigger: Trigger):
	var triggering_source: Variant = trigger.effect.source
	
	# Basic attack
	if triggering_source.name == &"Jaw Cruncher":
		exit_stance()


func fire_effect(effect: Effect) -> void:
	target = effect.target
	
	if effect.name == &"Jaw Cruncher":
		special()


# No longer used.
func do_action_as_target(action: Action):
	if action.name == &"basic_attack":
		pass
	await get_tree().create_timer(0.6).timeout
	hurt()


# Animation functions!
func hurt_target() -> void:
	if target == null: return
	target.actor.hurt()

func heal_target() -> void:
	if target == null: return
	target.actor.heal()


func hurt_random_target() -> void:
	var random_target: Character = Game.combat.effector.last_random_target
	if random_target == null: return
	random_target.actor.hurt()

func launch_ground_object() -> void:
	Game.combat.ground_objects.launch(global_position + Vector2(0.0, -400.0))


#
# Call these to trigger animations
#
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
