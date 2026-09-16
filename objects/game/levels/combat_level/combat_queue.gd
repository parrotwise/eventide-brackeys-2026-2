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

	var effect: Effect = _effect_queue[-1]
	
	if not effect:
		return
	
	await effect.apply(true)
	_effect_queue.erase(effect)
	
	var concurrents: Array[Effect] = Array(
		_effect_queue.filter(func(e): return e.source == effect.source),
		TYPE_OBJECT, &'Resource', Effect
	)

	for concurrent: Effect in concurrents:
		await concurrent.apply(true)
		_effect_queue.erase(concurrent)

	_effect_last_source = effect.source
	_effect_cooldown = effect_delay


func await_time(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func await_enemy_turn_delay() -> void:
	await await_time(1.5)


func await_round_delay() -> void:
	await await_time(2.5)


func await_action_delay() -> void:
	await await_time(2.5)


func await_empty() -> void:
	while not _effect_queue.is_empty():
		await await_time(0.2)


func await_effect(effect: Effect) -> void:
	while effect in _effect_queue:
		await await_time(0.2)
