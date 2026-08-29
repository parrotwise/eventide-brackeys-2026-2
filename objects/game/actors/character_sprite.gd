class_name CharacterSprite extends Sprite2D

# Initialization
func _ready() -> void:
	pass

# Set the shader parameters, deferred to make sure we get changed in frame_coords.
func _process(_delta: float) -> void:
	_process_deferred.call_deferred()
func _process_deferred():
	var shader_material: ShaderMaterial = (material as ShaderMaterial)
	shader_material.set_shader_parameter(&"uv_scale", Vector2(hframes, vframes))
	shader_material.set_shader_parameter(&"uv_shift", Vector2(frame_coords.x, frame_coords.y))
