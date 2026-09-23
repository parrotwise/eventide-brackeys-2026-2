class_name StatusBar
extends Control


static var status_icon_template: PackedScene = preload('res://objects/ui/status_icon.tscn')

var icon_container: HFlowContainer:
	get: return $StatusIconContainerAnchor/StatusIconContainer
var status_icons: Array[StatusIcon]:
	get: return Array(icon_container.get_children(), TYPE_OBJECT, &'Control', StatusIcon)


func add_icon(status: Status) -> void:
	if not status:
		return
	
	var status_icon := status_icon_template.instantiate() as StatusIcon
	status_icon.setup(status)
	icon_container.add_child(status_icon)

	reorder_icons()


func remove_icon(status: Status) -> void:
	if not status:
		return
	
	for status_icon: StatusIcon in status_icons:
		if status_icon.status == status:
			icon_container.remove_child(status_icon)
			status_icon.queue_free()
			return


func reorder_icons() -> void:
	var priority_order: Array[StatusIcon] = status_icons
	priority_order.sort_custom(func(a, b): return a.status.icon_priority > b.status.icon_priority)

	for icon: StatusIcon in priority_order:
		icon_container.move_child(icon, -1)
