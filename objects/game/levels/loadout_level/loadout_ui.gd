class_name LoadoutUI
extends CanvasLayer


@export var equipment_button_template: PackedScene

var character_lineup: CharacterLineup:
	get: return %CharacterLineup
var equipment_grid: EquipmentGrid:
	get: return %EquipmentGrid
var center_stage: CenterStage:
	get: return %CenterStage
var info_panel: InfoPanel:
	get: return %InfoPanel
var embark_button: TextureButton:
	get: return %EmbarkButton
var keyboard_reference: Panel:
	get: return $KeyboardReference
var settings_menu: SettingsMenu:
	get: return $SettingsMenu
var open_settings_button: ActionButton:
	get: return %OpenSettingsButton

var characters: Array[Character]:
	get: return character_lineup.characters


func _ready() -> void:
	## TODO: Replace with the commented-out callable after Wwise migration
	open_settings_button.pressed.connect(Audio.play_sfx.bind(Audio.Clip.UI_BUTTON))
	# open_settings_button.pressed.connect(Audio.post_event.bind(Audio.Event.UI_BUTTON))
	open_settings_button.pressed.connect(open_settings)
	open_settings_button.button.disabled = false

	Game.loadout_start.connect(_on_loadout_start)
	Game.loadout_end.connect(_on_loadout_end)


func refresh() -> void:
	equipment_grid.refresh()
	center_stage.refresh()
	info_panel.refresh()


func show_keyboard_reference() -> void:
	keyboard_reference.show()


func hide_keyboard_reference() -> void:
	keyboard_reference.hide()


func open_settings() -> void:
	settings_menu.show()
	

func _on_loadout_start() -> void:
	character_lineup.reset()
	equipment_grid.reset()

	embark_button.pressed.connect(Game.loadout.submit_allocation)


func _on_loadout_end() -> void:
	character_lineup.clear()
