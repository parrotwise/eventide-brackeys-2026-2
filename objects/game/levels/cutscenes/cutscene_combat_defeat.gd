extends Control


var curtain: ColorRect:
	get: return $Curtain
var skipper: CutsceneSkipper:
	get: return $Skipper


func _ready() -> void:
	skipper.skip_requested.connect(skip)
	
	curtain.color = Color(0, 0, 0, 0)

	await get_tree().create_timer(4).timeout

	get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(curtain, ^'color', Color.BLACK, 3)

	await get_tree().create_timer(5).timeout

	TransitionLayer.transition_simple_fade(TransitionLayer.credits, Color.BLACK)


func skip() -> void:
	TransitionLayer.transition_simple_fade(TransitionLayer.credits, Color.BLACK)
