class_name Actor extends Node2D
# Used to control a character visually

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func do_action_as_user(action: Action):
	if action.name == &"basic_attack":
		pass
	basic_attack()

func do_action_as_target(action: Action):
	if action.name == &"basic_attack":
		pass
	await get_tree().create_timer(0.6).timeout
	hurt()


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
	if animation_player.has_animation(&"idle"):
		animation_player.queue(&"idle")

func dead() -> void:
	pass

func heal() -> void:
	pass


func _ready() -> void:
	if animation_player.has_animation(&"idle"):
		animation_player.play(&"idle")

# Possible implementaitons in the future:
# enter_stance
# throw_projectile
# set_status
