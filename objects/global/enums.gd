extends Node


enum Direction {
	NONE,
	LEFT,
	RIGHT,
}

enum RangeType {
	ANY,
	SELF,
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
	USING_ACTION,
}

enum StackingType {
	UNIQUE,
	NON_STACKING,
	STACKING,
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
