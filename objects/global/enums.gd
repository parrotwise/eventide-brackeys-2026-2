extends Node


enum Direction {
	NONE,
	LEFT,
	RIGHT,
}

enum RangeType {
	ANY,
	MELEE,
	ADJACENT_ALLY,
}

enum BattleGroupType {
	ANY,
	OWN_GROUP,
	OTHER_GROUP,
}

enum TargetType {
	SELF,
	NEAREST_ENEMY,
	LAST_ATTACKER,
}

enum TriggerType {
	SOURCE_APPLIED,
	SOURCE_REMOVED,
	DAMAGE_TAKEN,
}

enum PointerType {
	DEFAULT,
	PRESSING,
	CLICKABLE,
	CLICKING,
	TARGET,
	ATTACK,
	SLOP,
	SWAP,
	DISABLED,
}
