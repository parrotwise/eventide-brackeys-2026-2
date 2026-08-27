class_name CharacterInput
extends Area2D


signal selected()
signal submitted()

var character: Character


func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(selected.emit)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed(&'select_character'):
		selected.emit()
	if event.is_action_pressed(&'submit_character'):
		submitted.emit()
