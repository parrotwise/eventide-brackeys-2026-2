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


func _ready() -> void:
	button.mouse_entered.connect(show_tooltip)
	button.mouse_exited.connect(hide_tooltip)

	icon.texture = icon_texture
	frame.texture = frame_texture
	background.texture = background_texture

	button.texture_normal = inner_texture_normal
	button.texture_hover = inner_texture_hover


## TODO: implement!
func show_tooltip() -> void:
	pass


## TODO: implement!
func hide_tooltip() -> void:
	pass
