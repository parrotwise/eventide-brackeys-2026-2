extends Node


signal start()
signal end()

var level: CombatLevel

func _ready() -> void:
	start.connect(Debug.info.bind('Game started.'))
	end.connect(Debug.info.bind('Game ended.'))
