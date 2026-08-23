class_name Equipment
extends Resource


var name: String
var description: String
var applied_to: Character

var attack_adder: float
var can_attack_twice: bool = false

var status_effects: Array[StatusEffect] = []


func modify_attack() -> float:
	return attack_adder
