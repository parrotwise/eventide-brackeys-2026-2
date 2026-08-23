extends Node


signal start()
signal end()

var level: GameLevel

func _ready() -> void:
	start.connect(Debug.info.bind('Game started.'))
	end.connect(Debug.info.bind('Game ended.'))
