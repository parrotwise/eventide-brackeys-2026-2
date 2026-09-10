class_name HealthBar
extends Control


@export var tween_duration: float = 0.9
@export var tween_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT

var frame: TextureRect:
	get: return $Frame
var top_bar: TextureProgressBar:
	get: return $TopBar
var bottom_bar: TextureProgressBar:
	get: return $BottomBar
var label: RichTextLabel:
	get: return $Label

var _tween: Tween


func _ready() -> void:
	frame.mouse_entered.connect(label.show)
	frame.mouse_exited.connect(label.hide)


func set_health(current_health: int, max_health: int) -> void:
	top_bar.max_value = max_health
	bottom_bar.max_value = max_health

	var losing_health: bool = current_health < top_bar.value
	var lead_bar: TextureProgressBar = top_bar if losing_health else bottom_bar
	var trail_bar: TextureProgressBar = bottom_bar if losing_health else top_bar

	lead_bar.value = current_health

	if _tween != null and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(trail_bar, "value", current_health, tween_duration) \
			.set_trans(tween_transition) \
			.set_ease(tween_ease)
	
	label.text = '%d / %d' % [current_health, max_health]
