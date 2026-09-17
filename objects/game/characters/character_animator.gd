class_name CharacterAnimator
extends AnimationPlayer


var character: Character


func _ready() -> void:
	Game.combat_start.connect(_on_combat_start)


func _on_combat_start() -> void:
	play(&'GunCat/Idle')
