class_name GroundObject
extends Node2D


@export var granted_status: Status
@export var despawn_on_status_removed: bool = false

var character: Character


func _ready() -> void:
	granted_status = granted_status.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

	Game.level.characters.character_removed.connect(_on_character_removed)
	Game.level.characters.characters_repositioned.connect(_on_characters_repositioned)


func _process(delta: float) -> void:
	if not is_instance_valid(character):
		return
	
	position = lerp(
		position, Game.level.characters.target_position(character),
		exp(-delta / Game.level.positioning_acceleration)
	)


func detach() -> void:
	if is_instance_valid(character):
		for status: Status in character.state_component.active_statuses:
			if status.name == granted_status.name:
				character.state_component.remove_status(status)
	
	character = null


func attach_to(new_character: Character) -> void:
	detach()
	character = new_character

	var applied_copy: Status = character.state_component.apply_status(granted_status)
	# Apply_status can return null
	if applied_copy == null: return
	if despawn_on_status_removed:
		applied_copy.removed.connect(func(_c): despawn(true))


func despawn(bypass_detach: bool = false) -> void:
	if not bypass_detach:
		detach()
	
	queue_free()


func _on_character_removed(removed_character: Character) -> void:
	if character == removed_character:
		var behind: Character = Game.level.characters.get_behind(character)
		if is_instance_valid(behind):
			attach_to(behind)
			return

		var ahead: Character = Game.level.characters.get_ahead_of(character)
		if is_instance_valid(ahead):
			attach_to(ahead)
			return
		
		despawn()


func _on_characters_repositioned(char_ahead: Character, char_behind: Character) -> void:
	if not is_instance_valid(char_ahead) or not is_instance_valid(char_behind):
		return
	
	var objs_ahead: Array[GroundObject] = Game.level.ground_objects.get_attached_to(char_ahead)
	var objs_behind: Array[GroundObject] = Game.level.ground_objects.get_attached_to(char_behind)

	for object: GroundObject in objs_ahead:
		object.attach_to(char_behind)

	for object: GroundObject in objs_behind:
		object.attach_to(char_ahead)
