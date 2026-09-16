class_name SettingsMenu
extends Control


@export_range(200, 2000, 200) var slider_min_speed: float = 1000
@export_range(5000, 10000, 1000) var slider_max_speed: float = 8000
@export_range(0.005, 0.015, 0.001) var slider_acceleration: float = 0.01

var close_button: ActionButton:
	get: return %CloseButton
var master_volume_slider: Slider:
	get: return %MasterVolumeSlider
var music_volume_slider: Slider:
	get: return %MusicVolumeSlider
var sfx_volume_slider: Slider:
	get: return %SFXVolumeSlider
var quit_button: Button:
	get: return %QuitButton

var focusables: Array[Control]:
	get: return [
		master_volume_slider,
		music_volume_slider,
		sfx_volume_slider,
		quit_button,
		close_button.button,
	]

var focused: Control:
	get:
		for focusable: Control in focusables:
			if focusable.has_focus():
				return focusable
		return null

var next_focusable: Control:
	get:
		var i: int = focusables.find(focused)
		if i == -1:
			return focusables[0]
		return focusables[(i + 1) % focusables.size()]

var prev_focusable: Control:
	get:
		var i: int = focusables.find(focused)
		if i == -1:
			return focusables[0]
		return focusables[(i - 1 + focusables.size()) % focusables.size()]

var slider_speed: float
var slider_decreasing: bool = false
var slider_increasing: bool = false


func _ready() -> void:
	for focusable: Control in focusables:
		focusable.focus_mode = Control.FOCUS_CLICK
	
	## TODO: Replace with the commented-out callable after Wwise migration
	close_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# close_button.pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	close_button.pressed.connect(hide)

	close_button.button.disabled = false

	master_volume_slider.value_changed.connect(_on_master_slider_value_changed)
	music_volume_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_slider_value_changed)

	quit_button.pressed.connect(Game.quit)
	quit_button.mouse_entered.connect(_on_mouse_enter)
	quit_button.mouse_exited.connect(_on_mouse_exit)


func _process(delta: float) -> void:
	if not is_instance_valid(focused):
		return
	
	if focused is not Range:
		return
	
	if not slider_decreasing and not slider_increasing:
		slider_speed = slider_min_speed
		return
	
	if slider_decreasing and slider_increasing:
		slider_speed = slider_min_speed
		return
	
	slider_speed = lerp(slider_speed, slider_max_speed, exp(-delta / slider_acceleration))

	focused.value = clampf(
		focused.value + focused.step * (1 if slider_increasing else -1) * slider_speed * delta,
		focused.min_value,
		focused.max_value
	)


func cycle_through_focusables(direction := Enums.Direction.RIGHT) -> void:
	if not visible:
		return
	
	if direction in [Enums.Direction.RIGHT, Enums.Direction.DOWN]:
		next_focusable.grab_focus()
	else:
		prev_focusable.grab_focus()


func submit_focused() -> void:
	if not focused:
		return
	
	if 'pressed' in focused:
		focused.pressed.emit()


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
