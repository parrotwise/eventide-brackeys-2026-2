class_name Trigger
extends Resource


@export var effect: Effect
@export var target_type: Enums.TargetType
@export var trigger_type: Enums.TriggerType
@export var bypass_queue: bool = false


func fire(specific_target: Character = null) -> void:
	if not effect:
		return
	
	var fired_effect: Effect = effect.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	fired_effect.source = effect.source
	fired_effect.owner = effect.owner

	if specific_target:
		fired_effect.target = specific_target
	
	else:
		match target_type:
			Enums.TargetType.SELF:
				fired_effect.target = fired_effect.owner
			Enums.TargetType.ALLY_AHEAD:
				fired_effect.target = Game.level.characters.get_ahead_of(fired_effect.owner)
			Enums.TargetType.ALLY_BEHIND:
				fired_effect.target = Game.level.characters.get_behind(fired_effect.owner)
			Enums.TargetType.NEAREST_ENEMY:
				fired_effect.target = (
					Game.level.characters.ally_melee
					if fired_effect.owner in Game.level.characters.enemies else
					Game.level.characters.enemy_melee
				)
			Enums.TargetType.CHARACTER_AHEAD:
				fired_effect.target = Game.level.characters.get_ahead_of(fired_effect.owner)
	
	# Resource instance modified in-place
	Game.level.status_tracker_component.modify_effect(fired_effect)
	
	await fired_effect.apply(bypass_queue)
	
	# Let the actor know of a triggered effect
	fired_effect.owner.actor.fire_effect(fired_effect)
