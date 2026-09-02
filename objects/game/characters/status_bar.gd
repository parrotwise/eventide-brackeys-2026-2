class_name StatusBar
extends Control


static var status_icon_template: PackedScene = preload('res://objects/ui/status_icon.tscn')

var icon_container: HFlowContainer:
	get: return $StatusIconContainer
var status_icons: Array[StatusIcon]:
	get: return Array(icon_container.get_children(), TYPE_OBJECT, &'Control', StatusIcon)


func add_icon(status: Status) -> void:
	if not status:
		return
	
	var status_icon: StatusIcon = status_icon_template.instantiate() as StatusIcon
	status_icon.setup(status)
	icon_container.add_child(status_icon)


func remove_icon(status: Status) -> void:
	if not status:
		return
	
	for status_icon: StatusIcon in status_icons:
		if status_icon.status == status:
			icon_container.remove_child(status_icon)
			status_icon.queue_free()
			return
