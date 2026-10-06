extends Control


@export_range(2, 50, 1) var scroll_speed: float = 10
@export_range(0.005, 0.15, 0.001) var scroll_acceleration: float = 0.008

var scroll_area: MarginContainer:
	get: return $ScrollArea
var container: MarginContainer:
	get: return $ScrollArea/Container
var content: VBoxContainer:
	get: return $ScrollArea/Container/Content
var logo: TextureRect:
	get: return $LogoArea/Logo

var target_y_offset: float = 0
var transitioning: bool = false


func _ready() -> void:
	scroll_area.position = Vector2.ZERO
	container.position = Vector2.ZERO
	logo.modulate = Color.TRANSPARENT


func _physics_process(delta: float) -> void:
	target_y_offset -= scroll_speed * delta * 10


func _process(delta: float) -> void:
	content.offset_transform_position.y = lerp(
		content.offset_transform_position.y, target_y_offset,
		exp(-delta / scroll_acceleration)
	)
	
	if transitioning:
		return
	
	if content.offset_transform_position.y < -container.size.y:
		transition()


func transition() -> void:
	transitioning = true

	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(logo, ^'modulate', Color.WHITE, 2)
	tween.tween_property(logo, ^'modulate', Color.WHITE, 5)
	tween.tween_property(logo, ^'modulate', Color.TRANSPARENT, 3)
	
	await get_tree().create_timer(10.5).timeout

	Game.restart()
