extends CanvasLayer


@export var combat_camera: CombatCamera
@export var target_character: Character

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
