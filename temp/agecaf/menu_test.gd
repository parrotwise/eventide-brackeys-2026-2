extends Control

func _ready() -> void:
	$CenterContainer/Button.pressed.connect(_on_play)

func _on_play() -> void:
	print("Pressed!")
	pass
