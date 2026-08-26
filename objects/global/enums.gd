extends Node


enum Direction {
	NONE,
	LEFT,
	RIGHT,
}

enum RangeType {
	MELEE,
	RANGED,
	ALLY,
}

enum TargetType {
	SELF,
	NEAREST_ENEMY,
	LAST_ATTACKER,
}

enum TriggerType {
	IMMEDIATE,
	DAMAGE_TAKEN,
}
