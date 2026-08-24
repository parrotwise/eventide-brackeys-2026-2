class_name Status
extends Resource


signal status_applied(character: Character)
signal status_removed(character: Character)
## Emitted when a status effect applies an effect independent of an action
## ex. Poison damage tick
signal status_triggered(character: Character, effects: Dictionary)

@export_group("Identifiers")
## A name to be exposed to the player.
@export var name: String
## A description to be exposed to the player.
@export_multiline() var description: String
## An icon to be exposed to the player.
@export var icon: Texture
@export var vfx: PackedScene

@export_group("Effect Definition")
## Value to be added to the owner's damage. Negative values subtract damage.
@export var damage_adder: float = 0
## Value to be added to the owner's health. Negative values subtract health.
@export var health_adder: float = 0
## Allows the owner to attack twice in one turn.
@export var can_attack_twice: bool = false

var _character: Character = null

func get_character() -> Character:
	return _character

func apply_to(character: Character) -> void:
	_character = character
	status_applied.emit(_character)

func remove_from() -> void:
	status_removed.emit(_character)
	_character = null
	
func trigger(effects: Dictionary = {}) -> void:
	status_triggered.emit(_character, effects)
	
func modify_action(action: Action, user: Character, target: Character) -> Action:
	var modified: Action = action.duplicate(true)
 
	if _character == user:
		if damage_adder != 0 and "damage" in modified:
			modified.damage += damage_adder
		if can_attack_twice and "can_attack_twice" in modified:
			modified.can_attack_twice = true
	
	if _character == target:
		if health_adder != 0 and "healing" in modified:
			modified.healing += health_adder
 
	return modified
