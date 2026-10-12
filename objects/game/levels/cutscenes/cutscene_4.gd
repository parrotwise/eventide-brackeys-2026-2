extends Control


var skipper: CutsceneSkipper:
	get: return $Skipper


func _ready() -> void:
	skipper.skip_requested.connect(skip)
	
	await get_tree().create_timer(7).timeout
	TransitionLayer.transition_betrayal(TransitionLayer.combat_level)


func skip() -> void:
	TransitionLayer.transition_betrayal(TransitionLayer.combat_level)
