extends Node

@export var event:WwiseEvent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Wwise.post_event("Ability_RC", self)
	$Button.pressed.connect(test_wwise)

func test_wwise() -> void:
	event.post(self)
