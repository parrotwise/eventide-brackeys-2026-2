class_name StatusIcon
extends Control


var icon: TextureRect:
	get: return $Icon
var button: TextureButton:
	get: return $InnerButton
var stack_label: RichTextLabel:
	get: return $StackLabel

var status: Status

var tooltip_header: String:
	get: return status.name if status else ''
var tooltip_description: String:
	get: return status.description if status else ''


func _process(_delta: float) -> void:
	if not status:
		return
	
	if status.stack == 1:
		stack_label.hide()
	
	else:
		stack_label.text = '%d' % [status.stack]
		stack_label.show()


func setup(new_status: Status) -> void:
	status = new_status

	if not status:
		icon.texture = null
		return
		
	icon.texture = status.icon
