extends Node


signal combat_start()
signal combat_end()
signal equipment_start()
signal equipment_end()

var loadout: LoadoutLevel
var combat: CombatLevel
var pointer: MousePointer


var inventories: Dictionary[String, Array] = {}	# Character.name : Array[Equipment]


func _ready() -> void:
	var pointer_layer: CanvasLayer = load('res://objects/ui/mouse_pointer.tscn').instantiate()
	get_tree().root.add_child.call_deferred(pointer_layer)
	pointer = pointer_layer.get_child(0) as MousePointer

	combat_start.connect(Debug.info.bind('Combat started.'))
	combat_end.connect(Debug.info.bind('Combat ended.'))

	equipment_start.connect(Debug.info.bind('Equipment allocation started.'))
	equipment_end.connect(Debug.info.bind('Equipment allocation ended.'))


func quit() -> void:
	get_tree().quit()
