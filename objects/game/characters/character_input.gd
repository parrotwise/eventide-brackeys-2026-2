class_name CharacterInput
extends Area2D


signal selected()
signal submitted()

var character: Character


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	input_event.connect(_on_input_event)


func _on_mouse_entered() -> void:
	selected.emit()


func _on_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(&'left_click'):
		# TODO: If no action selected, and target valid for basic attack XOR reposition, select that action first
		submitted.emit()
	elif event.is_action_pressed(&'right_click'):
		# TODO: If no action selected, and target valid for basic attack AND reposition, select reposition then submit as above
		viewport.set_input_as_handled()
