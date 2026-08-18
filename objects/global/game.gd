extends Node


signal start()
signal end()

var player: Player
var hazards: Array[Hazard] = []


func _ready() -> void:
	start.connect(Debug.info.bind('Game started.'))
	end.connect(Debug.info.bind('Game ended.'))
