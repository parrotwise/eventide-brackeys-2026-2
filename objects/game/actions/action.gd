class_name Action
extends Resource


signal used(user: Node, target: Node)


@export_category("Effects")

@export var damage: int = 0
@export var healing: int = 0


func use(user: Node, target: Node) -> void:
	used.emit(user, target)
