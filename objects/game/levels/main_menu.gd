extends Control


var start_button: TextureButton:
	get: return $StartButton
var options_button: TextureButton:
	get: return $OptionsButton
var settings_menu: SettingsMenu:
	get: return $SettingsMenu


func _ready() -> void:
	## TODO: Replace with the commented-out callable after Wwise migration
	start_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# open_settings_button.pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	start_button.pressed.connect(TransitionLayer.transition_simple_fade.bind(TransitionLayer.cutscene_1))

	## TODO: Replace with the commented-out callable after Wwise migration
	options_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# open_settings_button.pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	options_button.pressed.connect(settings_menu.show)


func _unhandled_input(event: InputEvent) -> void:
	if not settings_menu:
		return
	
	if event.is_action_pressed(&'escape'):
		settings_menu.visible = not settings_menu.visible
