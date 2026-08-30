extends Node


signal start()
signal end()

var level: CombatLevel
var pointer: MousePointer


var inventories: Dictionary[String, Array] = {}	# Character.name : Array[Equipment]


func _ready() -> void:
	var pointer_layer: CanvasLayer = load('res://objects/ui/mouse_pointer.tscn').instantiate()
	get_tree().root.add_child.call_deferred(pointer_layer)
	pointer = pointer_layer.get_child(0) as MousePointer

	start.connect(Debug.info.bind('Game started.'))
	end.connect(Debug.info.bind('Game ended.'))


func quit() -> void:
	get_tree().quit()
