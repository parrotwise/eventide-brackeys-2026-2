class_name CombatGroundObjects
extends Node2D

var last_object: GroundObject = null

var objects: Array[GroundObject]:
	get: return Array(get_children(), TYPE_OBJECT, &'Node2D', GroundObject)


func target_position(object: GroundObject) -> Vector2:
	if not is_instance_valid(object):
		return Vector2.ZERO

	return Game.level.characters.target_position(object.character)


func get_attached_to(character: Character) -> Array[GroundObject]:
	return Array(
		objects.filter(func(o): return o.character == character),
		TYPE_OBJECT, &'Node2D', GroundObject
	)

func launch(from_position: Vector2) -> void:
	if last_object == null: return
	last_object.global_position = from_position
	last_object.show()


func spawn(object_template: PackedScene, character: Character) -> void:
	var object: GroundObject = object_template.instantiate() as GroundObject
	add_child(object)
	if object.name != &'Sootgut':
		object.hide()
		last_object = object
	object.attach_to(character)
