extends CanvasLayer


@export var combat_camera: CombatCamera
@export var target_character: Character
@export var test_status: Status

var is_camera_zoomed: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
