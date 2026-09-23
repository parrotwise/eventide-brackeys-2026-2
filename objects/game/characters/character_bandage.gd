class_name CharacterBandage
extends Control


var tooltip: Tooltip:
	get: return $Tooltip

var character: Character

var tooltip_header: String:
	get: return 'Bandage'
var tooltip_description: String:
	get: return (
		'Heal %s for %d hit points.' % [
			character.id,
			mini(
				ceili(character.state.max_health * 0.3),
				character.state.max_health - character.state.current_health
			)
		]
	) if character else ''


var button: TextureButton:
	get: return $InnerButton



func _ready() -> void:
	Game.loadout_start.connect(refresh)
	
	button.pressed.connect(apply)
	button.mouse_entered.connect(_on_mouse_enter)
	button.mouse_exited.connect(_on_mouse_exit)
	
	refresh()


func apply() -> void:
	if not character:
		return
	
	character.state.heal(
		ceili(character.state.max_health * 0.3)
	)
	
	button.disabled = true

	refresh()
	
	Game.pointer.switch_to(Enums.PointerType.DEFAULT)


func refresh() -> void:
	visible = (
		Game.stage == Game.Stage.LOADOUT1
		and not button.disabled
		and is_instance_valid(character)
		and character.state.missing_health_ratio > 0
	)


func _on_mouse_enter() -> void:
	if button.disabled:
		return
	
	button.grab_focus()
	
	if Game.pointer.type in [Enums.PointerType.DEFAULT, Enums.PointerType.PRESSING]:
		Game.pointer.switch_to(Enums.PointerType.CLICKABLE)


func _on_mouse_exit() -> void:
	if button.disabled:
		return
	
	button.release_focus()
	
	if Game.pointer.type in [Enums.PointerType.CLICKABLE, Enums.PointerType.CLICKING]:
		Game.pointer.switch_to(Enums.PointerType.DEFAULT)
