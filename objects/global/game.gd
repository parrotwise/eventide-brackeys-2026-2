extends Node


signal start()
signal end()

var level: CombatLevel
var pointer: MousePointer


func _ready() -> void:
	pointer = load('res://objects/ui/mouse_pointer.tscn').instantiate() as MousePointer
	add_child(pointer)

	start.connect(Debug.info.bind('Game started.'))
	end.connect(Debug.info.bind('Game ended.'))
