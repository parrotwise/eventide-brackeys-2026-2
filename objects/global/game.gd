extends Node


signal combat_start()
signal combat_end()
signal equipment_start()
signal equipment_end()

enum Stage {
	LOADOUT1,
	COMBAT1,
	LOADOUT2,
	COMBAT2,
}

var loadout: LoadoutLevel
var combat: CombatLevel
var pointer: MousePointer

var stage: Stage = Stage.LOADOUT1
var inventories: Dictionary[String, Array] = {}	# Character.name : Array[Equipment]


func _ready() -> void:
	combat_start.connect(Debug.info.bind('Combat started.'))
	combat_end.connect(Debug.info.bind('Combat ended.'))

	equipment_start.connect(Debug.info.bind('Equipment allocation started.'))
	equipment_end.connect(Debug.info.bind('Equipment allocation ended.'))
	
	var pointer_layer: CanvasLayer = load('res://objects/ui/mouse_pointer.tscn').instantiate()
	get_tree().root.add_child.call_deferred(pointer_layer)
	pointer = pointer_layer.get_child(0) as MousePointer

	equipment_start.connect(func(): stage = Stage.LOADOUT2 if stage == Stage.COMBAT1 else Stage.LOADOUT1)
	combat_start.connect(func(): stage = Stage.COMBAT2 if stage == Stage.LOADOUT2 else Stage.COMBAT1)


func quit() -> void:
	get_tree().quit()
