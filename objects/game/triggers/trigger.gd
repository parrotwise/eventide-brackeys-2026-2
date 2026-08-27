class_name Trigger
extends Resource


@export var effect: Effect
@export var target_type: Enums.TargetType
@export var trigger_type: Enums.TriggerType


func fire(specific_target: Character = null) -> void:
	if specific_target:
		effect.target = specific_target
	
	else:
		match target_type:
			Enums.TargetType.SELF:
				effect.target = effect.owner
			Enums.TargetType.NEAREST_ENEMY:
				effect.target = (
					Game.level.characters.ally_melee
					if effect.owner in Game.level.characters.enemies else
					Game.level.characters.enemy_melee
				)
	
	# Resource instance modified in-place
	Game.level.status_tracker_component.modify_effect(effect)

	effect.apply()
