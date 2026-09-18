extends Node


signal combat_start()
signal combat_end()
signal loadout_start()
signal loadout_end()

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

var available_characters: Array[Character] = Array(
	[
		'gun_cat',
		'hook_cat',
		'explode_cat',
		'rum_cat',
		'nav_cat',
		'peanut_cat',
		'cook_cat',
		'big_cat',
	].map(func(char): return load('res://objects/game/characters/crewmembers/%s.tscn' % [char]).instantiate() as Character),
	TYPE_OBJECT, &'Node2D', Character
)

var available_equipment: Array[Equipment] = Array(
	[
		'burt_the_barnacle',
		'cannonball_necklace',
		'coin_with_a_bullet_hole',
		'crusty_smoking_pipe',
		'cursed_totem',
		'eelskin',
		'favorite_dagger',
		'gullbone_shiv',
		'hardtack_vest',
		'knuckle_o_salt',
		'mended_boot',
		'nipium_keepsake',
		'old_key',
		'pocket_of_jerky',
		'rope_loop',
		'sailcloth_sash',
		'secret_mixture',
		'shark_tooth',
		'spiked_armband',
		'strange_looking_orange',
	].map(func(item): return load('res://objects/game/equipments/equipment_%s.tres' % [item])),
	TYPE_OBJECT, &'Resource', Equipment
)

var allies: Array[Character] = available_characters.duplicate(false)
var enemies: Array[Character] = []

var inventories: Dictionary[String, Array] = {}	# Character.name : Array[Equipment]


func _ready() -> void:
	combat_start.connect(Debug.info.bind('Combat started.'))
	combat_end.connect(Debug.info.bind('Combat ended.'))

	loadout_start.connect(Debug.info.bind('Loadout started.'))
	loadout_end.connect(Debug.info.bind('Loadout ended.'))
	
	var pointer_layer: CanvasLayer = load('res://objects/ui/mouse_pointer.tscn').instantiate()
	get_tree().root.add_child.call_deferred(pointer_layer)
	pointer = pointer_layer.get_child(0) as MousePointer

	loadout_start.connect(func(): stage = Stage.LOADOUT2 if stage == Stage.COMBAT1 else Stage.LOADOUT1)
	combat_start.connect(func(): stage = Stage.COMBAT2 if stage == Stage.LOADOUT2 else Stage.COMBAT1)


func quit() -> void:
	get_tree().quit()
