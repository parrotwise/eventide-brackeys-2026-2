class_name CombatPreview
extends Node


func preview_action(action: Action, user: Character, target: Character) -> void:
	if not action or not user or not target:
		return
	
	hide_previews()
	
	var effects: Array[Effect] = (
		Game.level.effector_component.interpret(action, user, target)
	).values()

	for effect: Effect in effects:
		effect.target.indicators_component.preview_bar.add_icons_for(effect)

		for extra: Effect in effect.extra_effects:
			extra.target.indicators_component.preview_bar.add_icons_for(extra)


func hide_previews() -> void:
	for character: Character in Game.level.characters.all:
		character.indicators_component.hide_previews()
