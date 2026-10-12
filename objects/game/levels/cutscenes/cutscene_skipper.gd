class_name CutsceneSkipper
extends Control


signal skip_requested()

@export_range(0.0, 3.0, 0.2) var hold_threshold: float = 1.0

var feedback_text: RichTextLabel:
	get: return $FeedbackText

var held_time: float
var suppressed: bool


func _ready() -> void:
	held_time = 0
	suppressed = false


func _process(delta: float) -> void:
	feedback_text.hide()
	
	if suppressed:
		if not Input.is_action_pressed(&'escape'):
			suppressed = false
		
		return
	
	feedback_text.visible = Input.is_action_pressed(&'escape')
	
	if Input.is_action_pressed(&'escape'):
		held_time += delta
		
		if held_time > hold_threshold:
			suppressed = true
			skip_requested.emit()
	
	else:
		held_time = 0
