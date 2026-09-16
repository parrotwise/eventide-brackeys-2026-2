class_name Trigger
extends Resource


signal fired()

@export var effect: Effect
@export var target_type: Enums.TargetType
@export var trigger_type: Enums.TriggerType
@export var bypass_queue: bool = false

var source: Status


func fire(specific_target: Character = null) -> void:
	if not effect:
		return
	
	fired.emit()

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
	
	# Let the actor know of a triggered effect, if the character is still alive
	if is_instance_valid(fired_effect.owner.actor):
		fired_effect.owner.actor.fire_effect(fired_effect)
	
	if not source:
		return
	
	if source.trigger_uses > 0:
		source.trigger_uses -= 1
		
		if not source.trigger_uses:
			source.remove_trigger(self)
			
			if source.remove_when_triggers_used_up:
				if is_instance_valid(source.owner):
					source.owner.state_component.remove_status(source)
