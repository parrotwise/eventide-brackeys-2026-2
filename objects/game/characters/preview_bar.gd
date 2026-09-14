class_name PreviewBar
extends Control


static var preview_icon_template: PackedScene = preload('res://objects/ui/preview_icon.tscn')

var icon_container: HFlowContainer:
	get: return $PreviewIconContainerAnchor/PreviewIconContainer
var preview_icons: Array[PreviewIcon]:
	get: return Array(icon_container.get_children(), TYPE_OBJECT, &'Control', PreviewIcon)


func add_icons_for(effect: Effect) -> void:
	if not effect:
		return
	
	var on_enemy: bool = effect.target in Game.level.characters.enemies
	
	if effect.stacked_damage:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.DAMAGE, effect.stacked_damage, on_enemy)
	
	if effect.stacked_damage_explosive:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.DAMAGE_EXPLOSIVE, effect.stacked_damage_explosive, on_enemy)
	
	if effect.stacked_damage_poison:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.POISONED, effect.stacked_damage_poison, on_enemy)
	
	if effect.stacked_healing:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.HEALING, effect.stacked_healing, on_enemy)
	
	if effect.stacked_healing_ratio:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.HEALING, ceili(effect.stacked_healing_ratio * effect.target.state_component.max_health), on_enemy)
	
	if effect.swap_places:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.SWAP, '', on_enemy)
	
	if effect.knockback_steps or effect.knockback_to_rear:
		var steps: int = 0
		var probe: Character = Game.level.characters.get_behind(effect.target, true)

		for i: int in (99 if effect.knockback_to_rear else effect.knockback_steps):
			if not probe or not probe.state_component.can_move:
				break
			
			steps += 1
			probe = Game.level.characters.get_behind(probe, true)

		if steps:
			icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
			preview_icons[-1].setup(PreviewIcon.IconType.KNOCKBACK, steps, on_enemy)
	
	if effect.pull_steps or effect.pull_to_front:
		var steps: int = 0
		var probe: Character = Game.level.characters.get_ahead_of(effect.target, true)

		for i: int in (99 if effect.pull_to_front else effect.pull_steps):
			if not probe or not probe.state_component.can_move:
				break
			
			steps += 1
			probe = Game.level.characters.get_ahead_of(probe, true)

		if steps:
			icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
			preview_icons[-1].setup(PreviewIcon.IconType.PULL, steps, on_enemy)
	
	if effect.crunch_peanuts:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.PEANUTS, '', on_enemy)
	
	if effect.reattach_sootgut:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.SOOTGUT, '', on_enemy)
	
	for status: Status in effect.applied_statuses:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)

		match status.name:
			'Jaw Cruncher':
				preview_icons[-1].setup(PreviewIcon.IconType.CHARGING, '', on_enemy)
			'High Spirits':
				preview_icons[-1].setup(PreviewIcon.IconType.DAMAGE_DEALT_UP, '', on_enemy)
			'Immobilized':
				preview_icons[-1].setup(PreviewIcon.IconType.IMMOBILIZED, '', on_enemy)
			'Laser-Focused':
				preview_icons[-1].setup(PreviewIcon.IconType.HEALING_RECEIVED_UP, '', on_enemy)
				icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
				preview_icons[-1].setup(PreviewIcon.IconType.DAMAGE_TAKEN_UP, '', on_enemy)
			'Mug Toss':
				preview_icons[-1].setup(PreviewIcon.IconType.DAMAGE_DEALT_UP, '', on_enemy)
			'Nasty Cuts':
				preview_icons[-1].setup(PreviewIcon.IconType.NASTY_CUTS, '', on_enemy)
			'No More Please':
				preview_icons[-1].setup(PreviewIcon.IconType.NO_MORE_PLEASE, '', on_enemy)
			'Old Key Boost':
				preview_icons[-1].setup(PreviewIcon.IconType.DAMAGE_DEALT_UP, '', on_enemy)
			'Poisoned':
				preview_icons[-1].setup(PreviewIcon.IconType.POISONED, '', on_enemy)
			'Smashed':
				preview_icons[-1].setup(PreviewIcon.IconType.SMASHED, '', on_enemy)
			'Stunned':
				preview_icons[-1].setup(PreviewIcon.IconType.STUNNED, '', on_enemy)
			'Unflinching':
				preview_icons[-1].setup(PreviewIcon.IconType.DAMAGE_DEALT_UP, '', on_enemy)
			_:
				preview_icons[-1].setup(PreviewIcon.IconType.NONE, '', on_enemy)
	
	for object_template: PackedScene in effect.created_objects:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		
		# TODO: Find a better way or come to terms with your despicable methods
		var object := object_template.instantiate() as GroundObject

		match object.granted_status.name:
			'Peanuts':
				preview_icons[-1].setup(PreviewIcon.IconType.PEANUTS, '', on_enemy)
			'Powder Satchel':
				preview_icons[-1].setup(PreviewIcon.IconType.POWDER_SATCHEL, '', on_enemy)
			'Sootgut':
				preview_icons[-1].setup(PreviewIcon.IconType.SOOTGUT, '', on_enemy)
			_:
				preview_icons[-1].setup(PreviewIcon.IconType.NONE, '', on_enemy)
		
		object.queue_free()
	
	if effect.repeat_on_target:
		icon_container.add_child(preview_icon_template.instantiate() as PreviewIcon)
		preview_icons[-1].setup(PreviewIcon.IconType.STRAY_BULLET, '', on_enemy)


func clear_icons() -> void:
	for preview_icon: PreviewIcon in preview_icons.duplicate():
		icon_container.remove_child(preview_icon)
		preview_icon.queue_free()
