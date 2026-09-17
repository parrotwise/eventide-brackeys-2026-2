class_name CombatPreview
extends Node


func preview_action(action: Action, user: Character, target: Character) -> void:
	if not action or not user or not target:
		return
	
	hide_previews()
	
	var effects: Array[Effect] = (
		Game.combat.effector.interpret(action, user, target)
	).values()

	for effect: Effect in effects:
		effect.target.indicators.preview_bar.add_icons_for(effect)

		for extra: Effect in effect.extra_effects:
			extra.target.indicators.preview_bar.add_icons_for(extra)


func hide_previews() -> void:
	for character: Character in Game.combat.characters.all:
		character.indicators.hide_previews()
