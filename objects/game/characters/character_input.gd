class_name CharacterInput
extends Area2D


signal selected()
signal deselected()
signal submitted(character: Character)

var input_area: CollisionPolygon2D:
	get: return $InputArea

var character: Character


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)


func set_flip(flip: bool = true) -> void:
	input_area.scale = Vector2(-1, 1) if flip else Vector2.ONE


func submit_as_target() -> void:
	if not is_instance_valid(Game.combat):
		if is_instance_valid(Game.loadout):
			submitted.emit(character)
		return
	
	if not is_instance_valid(Game.combat.selector.current_action):
		return

	if not is_instance_valid(Game.combat.selector.current_target):
		return

	if Game.combat.selector.current_target != character:
		return
	
	submitted.emit(character)


func _on_mouse_entered() -> void:
	selected.emit()
	character.label.show()


func _on_mouse_exited() -> void:
	deselected.emit()
	character.label.hide()
	Game.pointer.return_to_previous()


func _on_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(&'left_click'):
		submit_as_target()
		viewport.set_input_as_handled()
