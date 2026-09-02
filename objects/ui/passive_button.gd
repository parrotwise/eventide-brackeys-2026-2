class_name PassiveButton
extends Control


@export var icon_texture: Texture2D
@export var frame_texture: Texture2D
@export var inner_texture_normal: Texture2D
@export var inner_texture_hover: Texture2D
@export var background_texture: Texture2D

var icon: TextureRect:
	get: return $Icon
var frame: TextureRect:
	get: return $Frame
var button: TextureButton:
	get: return $InnerButton
var background: TextureRect:
	get: return $Background

var passive: Status

var tooltip_header: String:
	get: return passive.name if passive else ''
var tooltip_description: String:
	get: return passive.description if passive else ''


func _ready() -> void:
	frame.texture = frame_texture
	background.texture = background_texture


func setup(new_passive: Status) -> void:
	passive = new_passive

	if not passive:
		button.texture_normal = null
		button.texture_hover = null
		return
		
	button.texture_normal = passive.passive_icon_normal
	button.texture_hover = passive.passive_icon_hover
