class_name HealthBar
extends Control

@export var tween_duration: float = 0.9
@export var tween_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT

@onready var _top_bar: TextureProgressBar = $TopBar
@onready var _bottom_bar: TextureProgressBar = $BottomBar

var _tween: Tween

func set_health(current_health: int, max_health: int) -> void:
	_top_bar.max_value = max_health
	_bottom_bar.max_value = max_health

	var losing_health: bool = current_health < _top_bar.value
	var lead_bar: TextureProgressBar = _top_bar if losing_health else _bottom_bar
	var trail_bar: TextureProgressBar = _bottom_bar if losing_health else _top_bar

	lead_bar.value = current_health

	if _tween != null and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(trail_bar, "value", current_health, tween_duration) \
			.set_trans(tween_transition) \
			.set_ease(tween_ease)
