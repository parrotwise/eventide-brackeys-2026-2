class_name CombatScenery
extends Control


var big_comet: AnimatedSprite2D:
	get: return $MidParallax/BigComet
var big_comet_timer: Timer:
	get: return $MidParallax/BigComet/BigCometTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_big_comet_timer_timeout() -> void:
	big_comet.play()
	big_comet_timer.wait_time = randf_range(5, 15)
