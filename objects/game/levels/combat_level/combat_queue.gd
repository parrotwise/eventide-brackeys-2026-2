class_name CombatQueue
extends Node


@export_range(0.2, 3.0, 0.2) var effect_delay: float = 1.0

var _effect_queue: Array[Effect] = []
var _effect_cooldown: float = 0.0
var _effect_last_source: Variant


func _process(delta: float) -> void:
	_effect_cooldown -= delta
	if _effect_cooldown <= 0:
		pop_effect()


func push_effect(effect: Effect) -> void:
	_effect_queue.push_back(effect)


func pop_effect() -> void:
	if not _effect_queue:
		return

	var effect: Effect = _effect_queue.pop_back()

	if not effect:
		return
	
	effect.apply(true)
	
	var concurrents: Array[Effect] = Array(
		_effect_queue.filter(func(e): return e.source == effect.source),
		TYPE_OBJECT, &'Resource', Effect
	)

	for concurrent: Effect in concurrents:
		_effect_queue.erase(concurrent)
		concurrent.apply(true)

	_effect_last_source = effect.source
	_effect_cooldown = effect_delay


func await_empty() -> void:
	while not _effect_queue.is_empty():
		await get_tree().create_timer(0.2).timeout


func await_effect(effect: Effect) -> void:
	while effect in _effect_queue:
		await get_tree().create_timer(0.2).timeout
