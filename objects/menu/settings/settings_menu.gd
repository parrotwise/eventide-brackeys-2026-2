class_name SettingsMenu
extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/VolumeContainer/VolumeSlider.value_changed.connect(_on_slider_value_changed)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/QuitButton.pressed.connect(Game.quit)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/QuitButton.mouse_entered.connect(_on_mouse_enter)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/QuitButton.mouse_exited.connect(_on_mouse_exit)


func _on_slider_value_changed(value: float) -> void:
	Audio.master_volume = value


func _on_mouse_enter() -> void:
	if Game.pointer.type in [Enums.PointerType.DEFAULT, Enums.PointerType.PRESSING]:
		Game.pointer.switch_to(Enums.PointerType.CLICKABLE)

func _on_mouse_exit() -> void:
	if Game.pointer.type in [Enums.PointerType.CLICKABLE, Enums.PointerType.CLICKING]:
		Game.pointer.switch_to(Enums.PointerType.DEFAULT)
