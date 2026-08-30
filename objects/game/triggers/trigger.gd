class_name Trigger
extends Resource


@export var effect: Effect
@export var target_type: Enums.TargetType
@export var trigger_type: Enums.TriggerType
@export var bypass_queue: bool = false


func fire(specific_target: Character = null) -> void:
	if specific_target:
		effect.target = specific_target
	
	else:
		match target_type:
			Enums.TargetType.SELF:
				effect.target = effect.owner
			Enums.TargetType.ALLY_AHEAD:
				effect.target = Game.level.characters.get_ahead_of(effect.owner)
			Enums.TargetType.ALLY_BEHIND:
				effect.target = Game.level.characters.get_behind(effect.owner)
			Enums.TargetType.NEAREST_ENEMY:
				effect.target = (
					Game.level.characters.ally_melee
					if effect.owner in Game.level.characters.enemies else
					Game.level.characters.enemy_melee
				)
			Enums.TargetType.CHARACTER_AHEAD:
				effect.target = Game.level.characters.get_ahead_of(effect.owner)
	
	# Resource instance modified in-place
	Game.level.status_tracker_component.modify_effect(effect)
	
	effect.apply(bypass_queue)
	
	# Let the actor know of a triggered effect
	effect.owner.actor.fire_effect(effect)
