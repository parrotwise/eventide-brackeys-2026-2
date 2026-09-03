class_name SettingsMenu
extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/VolumeContainer/MasterVolumeSlider.value_changed.connect(_on_master_slider_value_changed)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/VolumeContainer2/MusicVolumeSlider.value_changed.connect(_on_music_slider_value_changed)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/VolumeContainer3/SFXVolumeSlider.value_changed.connect(_on_sfx_slider_value_changed)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/QuitButton.pressed.connect(Game.quit)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/QuitButton.mouse_entered.connect(_on_mouse_enter)
	$CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/QuitButton.mouse_exited.connect(_on_mouse_exit)


func _on_master_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("Vol_Master", value, null)

func _on_music_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("Vol_Music", value, null)

func _on_sfx_slider_value_changed(value: float) -> void:
	Wwise.set_rtpc_value("Vol_SFX", value, null)


func _on_mouse_enter() -> void:
	if Game.pointer.type in [Enums.PointerType.DEFAULT, Enums.PointerType.PRESSING]:
		Game.pointer.switch_to(Enums.PointerType.CLICKABLE)

func _on_mouse_exit() -> void:
	if Game.pointer.type in [Enums.PointerType.CLICKABLE, Enums.PointerType.CLICKING]:
		Game.pointer.switch_to(Enums.PointerType.DEFAULT)
