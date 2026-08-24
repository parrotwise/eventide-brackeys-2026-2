extends GridContainer


var ability_buttons: Array[TextureButton]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Gather references to the buttons for later use. Use a loop to get around type error.
	for node in get_children():
		ability_buttons.append(node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _update_ability_buttons(char: Character) -> void:
	# Maybe we get abilities from the selected character. Or maybe from an
	# ActionsComponent or SelectorComponent, in which case the `char` input is not needed.
	for button: TextureButton in ability_buttons:
		pass # TODO: update button textures & action resources/references.
