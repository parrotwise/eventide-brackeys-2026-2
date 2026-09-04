extends CanvasLayer


@export var combat_camera: CombatCamera
@export var target_character: Character
@export var test_status: Status

var is_camera_zoomed: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("enter_debug"):
		visible = !visible


func _on_shake_screen_button_pressed() -> void:
	combat_camera.shake_screen()


func _on_zoom_button_pressed() -> void:
	if !is_camera_zoomed:
		combat_camera.zoom_on_characters([target_character])
		is_camera_zoomed = true
	else:
		combat_camera.zoom_to_full()
		is_camera_zoomed = false


func _on_take_damage_button_pressed() -> void:
	target_character.state_component.take_damage(25)


func _on_heal_button_pressed() -> void:
	target_character.state_component.heal(25)


func _on_apply_status_pressed() -> void:
	target_character.state_component.apply_status(test_status)


func _on_remove_status_pressed() -> void:
	for status: Status in target_character.state_component.active_statuses:
		if status.name == test_status.name:
			target_character.state_component.remove_status(status)
			return


func _on_select_character_pressed() -> void:
	Game.level.selector_component.select_ally(
		Random.randsample(Game.level.characters.allies)
	)


func _on_select_action_pressed() -> void:
	Game.level.selector_component.select_action(
		Random.randsample(Game.level.selector_component.current_user.actions)
	)


func _on_select_target_pressed() -> void:
	Game.level.selector_component.select_target(
		Random.randsample(Game.level.selector_component.current_action.valid_targets())
	)


func _on_spawn_cauldron() -> void:
	Game.level.ground_objects.spawn(
		load('res://objects/game/ground_objects/cauldron.tscn'),
		Game.level.characters.allies[1]
	)


func _on_despawn_cauldron() -> void:
	Random.randsample(Game.level.ground_objects.objects).despawn()


func _on_move_cauldron_dude() -> void:
	Game.level.characters._move_by(
		Random.randint(0, 1) * 2 - 1,
		Random.randsample(Game.level.ground_objects.objects).character
	)


func _on_kill_cauldron_dude() -> void:
	Game.level.characters.remove(
		Random.randsample(Game.level.ground_objects.objects).character
	)
