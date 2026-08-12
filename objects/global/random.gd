class_name Random
extends Resource


static var rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func randfloat(range_min: float = 0.0, range_max: float = 1.0) -> float:
	return rng.randf_range(min(range_min, range_max), max(range_min, range_max))


static func randint(range_min: int = 0, range_max: int = 4_294_967_295) -> int:
	return rng.randi_range(min(range_min, range_max), max(range_min, range_max))


static func randindex(array: Array) -> int:
	return randint(0, array.size() - 1)


static func randsample(array: Array) -> Variant:
	return array[randindex(array)] if array else null


static func shuffle(array: Array) -> Array:
	var elements: Array = array.duplicate()
	var shuffled: Array = []

	while elements:
		shuffled.append(elements.pop_at(randindex(elements)))
	
	return shuffled
