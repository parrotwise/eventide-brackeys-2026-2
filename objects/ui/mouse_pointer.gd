class_name MousePointer
extends Control


@onready var _sprite_map: Dictionary[Enums.PointerType, Sprite2D] = {
	Enums.PointerType.DEFAULT: $Default,
	Enums.PointerType.PRESSING: $Pressing,
	Enums.PointerType.CLICKABLE: $Clickable,
	Enums.PointerType.CLICKING: $Clicking,
	Enums.PointerType.TARGET: $Target,
	Enums.PointerType.ATTACK: $Attack,
	Enums.PointerType.SLOP: $Slop,
	Enums.PointerType.SWAP: $Swap,
	Enums.PointerType.DISABLED: $Disabled,
}

var type: Enums.PointerType


func _ready() -> void:
	switch_to(Enums.PointerType.DEFAULT)


func switch_to(pointer_type: Enums.PointerType) -> void:
	hide_all()
	_sprite_map[pointer_type].show()
	type = pointer_type


func hide_all() -> void:
	for sprite: Sprite2D in _sprite_map.values():
		sprite.hide()


func _process(_delta: float) -> void:
	var mouse_pressed: bool = (
		Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	)

	if mouse_pressed:
		if type == Enums.PointerType.DEFAULT:
			switch_to(Enums.PointerType.PRESSING)
		elif type == Enums.PointerType.CLICKABLE:
			switch_to(Enums.PointerType.CLICKING)
	
	else:
		if type == Enums.PointerType.PRESSING:
			switch_to(Enums.PointerType.DEFAULT)
		elif type == Enums.PointerType.CLICKING:
			switch_to(Enums.PointerType.CLICKABLE)
	
	global_position = get_global_mouse_position()
