class_name SettingsMenu
extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/VolumeContainer/VolumeSlider.value_changed.connect(_on_slider_value_changed)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/QuitButton.pressed.connect(Game.quit)


func _on_slider_value_changed(value: float) -> void:
	Audio.master_volume = value
