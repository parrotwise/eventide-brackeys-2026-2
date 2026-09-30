class_name CharacterBandage
extends Control


var uses_label: RichTextLabel:
	get: return $UsesLabel

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
	button.pressed.connect(apply)
	button.mouse_entered.connect(_on_mouse_enter)
	button.mouse_exited.connect(_on_mouse_exit)
	
	refresh()


func apply() -> void:
	if Game.stage != Game.Stage.LOADOUT2:
		return
	if not character:
		return
	
	Game.loadout.bandage_uses -= 1
	
	character.state.heal(
		ceili(character.state.max_health * 0.3)
	)
	
	button.disabled = true

	for c: Character in Game.loadout.characters:
		c.bandage_button.refresh()
	
	Game.pointer.switch_to(Enums.PointerType.DEFAULT)


func refresh() -> void:
	visible = (
		Game.stage == Game.Stage.LOADOUT2
		and not button.disabled
		and is_instance_valid(character)
		and Game.loadout.bandage_uses
		and character.state.missing_health_ratio > 0
	)

	if not visible:
		return

	uses_label.text = str(Game.loadout.bandage_uses)
	uses_label.visible = visible


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
