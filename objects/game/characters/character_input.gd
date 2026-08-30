class_name CharacterInput
extends Area2D


signal selected()
signal submitted()

var input_area: CollisionPolygon2D:
	get: return $InputArea

var character: Character


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)


func set_flip(flip: bool = true) -> void:
	input_area.scale = Vector2(-1, 1) if flip else Vector2.ONE


func _on_mouse_entered() -> void:
	selected.emit()
	character.label.show()


func _on_mouse_exited() -> void:
	character.label.hide()


func _on_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(&'left_click'):
		# TODO: If no action selected, and target valid for basic attack XOR reposition, select that action first
		submitted.emit()
	elif event.is_action_pressed(&'right_click'):
		# TODO: If no action selected, and target valid for basic attack AND reposition, select reposition then submit as above
		viewport.set_input_as_handled()
