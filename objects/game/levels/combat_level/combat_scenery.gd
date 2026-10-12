class_name CombatScenery
extends Control


enum FGType {
	NONE,
	COMBAT1,
	COMBAT2,
}


var big_comet: AnimatedSprite2D:
	get: return $MidParallax/BigComet
var big_comet_timer: Timer:
	get: return $MidParallax/BigComet/BigCometTimer
var foreground: TextureRect:
	get: return $Foreground


func _ready() -> void:
	switch_fg(
		FGType.COMBAT1
		if Game.stage < Game.Stage.COMBAT1 else
		FGType.COMBAT2
	)


func _on_big_comet_timer_timeout() -> void:
	big_comet.play()
	big_comet_timer.wait_time = randf_range(5, 15)


func switch_fg(type: FGType) -> void:
	match type:
		FGType.COMBAT1:
			foreground.texture = load('res://assets/art/backgrounds/bg_deck_b1.png')
		FGType.COMBAT2:
			foreground.texture = load('res://assets/art/backgrounds/bg_deck_b2.png')
