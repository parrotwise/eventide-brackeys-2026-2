extends Control


@export var equipment: Equipment

var eq_icon: TextureRect:
	get: return $ButtonBG/TextureButton/MarginContainer/Icon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check if the button has an equipment assigned. If not, hide self.
	if !equipment:
		hide()
		return
	
	eq_icon.texture = equipment.icon
