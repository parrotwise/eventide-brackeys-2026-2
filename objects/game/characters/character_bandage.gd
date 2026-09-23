class_name CharacterBandage
extends Control


var character: Character

var tooltip_header: String:
	get: return (
		'Bandage %s' % character.id
	) if character else ''
var tooltip_description: String:
	get: return (
		'Heal %d hit points.' % mini(
			ceili(character.state.max_health * 0.3),
			character.state.max_health - character.state.current_health
		)
	) if character else ''


var button: TextureButton:
	get: return $InnerButton



func _ready() -> void:
	Game.loadout_start.connect(refresh)
	
	button.pressed.connect(apply)
	
	refresh()


func apply() -> void:
	if not character:
		return
	
	character.state.heal(
		ceili(character.state.max_health * 0.3)
	)
	
	button.disabled = true

	refresh()


func refresh() -> void:
	visible = Game.stage == Game.Stage.LOADOUT2 and not button.disabled
