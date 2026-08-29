extends Control


var betrayal_splash: TextureRect:
	get: return $BetrayalSplash


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	betrayal_splash.modulate.a = 0
	
	await get_tree().create_timer(2).timeout
	
	var narrative_tween = create_tween()
	narrative_tween.tween_property(betrayal_splash, "modulate:a", 1, 0.4)
	
	await narrative_tween.finished
	TransitionLayer.simple_fade(TransitionLayer.combat_level)
