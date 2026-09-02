class_name StatusIcon
extends Control


var icon: TextureRect:
	get: return $Icon
var button: TextureButton:
	get: return $InnerButton

var status: Status

var tooltip_header: String:
	get: return status.name if status else ''
var tooltip_description: String:
	get: return status.description if status else ''


func setup(new_status: Status) -> void:
	status = new_status

	if not status:
		icon.texture = null
		return
		
	icon.texture = status.icon
