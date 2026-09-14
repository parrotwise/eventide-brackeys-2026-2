class_name PreviewIcon
extends Control


enum IconType {
	NONE,
	DAMAGE,
	DAMAGE_EXPLOSIVE,
	HEALING,
	STRAY_BULLET,
	PEANUTS,
	POWDER_SATCHEL,
	SOOTGUT,
	KNOCKBACK,
	PULL,
	SWAP,
	CHARGING,
	DAMAGE_DEALT_UP,
	DAMAGE_TAKEN_UP,
	FLAMMABLE,
	HEALING_RECEIVED_UP,
	IMMOBILIZED,
	NASTY_CUTS,
	NO_MORE_PLEASE,
	POISONED,
	SMASHED,
	STUNNED,
}

@export var icon_textures: Dictionary[IconType, Texture2D]
@export var mirroring_icons: Array[IconType]

var icon: TextureRect:
	get: return $Icon
var value_label: RichTextLabel:
	get: return $ValueLabel


func setup(icon_type: IconType, value: Variant, on_enemy: bool = true) -> void:
	icon.texture = icon_textures.get(icon_type, null)
	icon.visible = icon.texture != null
	icon.flip_h = icon_type in mirroring_icons and not on_enemy

	value_label.text = '%s' % [value]
	value_label.visible = not not value
