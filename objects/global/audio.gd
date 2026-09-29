extends Node


## TODO: Add one item per Wwise event.
enum Event {
	NONE,
	ATTACK_BC,
	ATTACK_BHC,
	ATTACK_EC,
	ATTACK_GC,
	ATTACK_NC,
	ATTACK_PC,
	ATTACK_RC,
	ATTACK_SC,
	SKILL_BC_CHARGE,
	SKILL_BC_SLAM,
	SKILL_BHC,
	SKILL_EC,
	SKILL_GC,
	SKILL_NC,
	SKILL_PC,
	SKILL_RC,
	SKILL_SC,
}

## TODO: Add one item per Wwise StateGroup+State combination.
enum State {
	NONE,
	INTRO,
	PRECOMBAT,
	COMBAT,
}

## TODO: Add one item per Wwise SwitchGroup.
enum Switch {
	NONE,
	NORMAL,
	SMASHED,
}

## TODO: Deprecated! Replace with the enums above.
enum Clip {
	NONE,
	BC_ABILITY_CHARGE,
	BC_ABILITY_SLAM,
	BC_ATTACK,
	BHC_ABILITY,
	BHC_ATTACK,
	EC_ABILITY,
	EC_ATTACK,
	EC_ATTACK_NO_FUSE,
	GC_ABILITY,
	GC_ATTACK,
	PC_ABILITY,
	PC_ATTACK,
	RC_ABILITY,
	RC_ATTACK,
	SC_ABILITY,
	SC_ATTACK,
	NC_ABILITY,
	NC_ATTACK,
	EAT_CRUNCH,
	UI_BUTTON,
}

## TODO: Deprecated! Replace with the enums above.
enum Track {
	TRACK1,
	TRACK2,
}

var master_volume: float = 0.5
var music_volume: float = 0.5
var sfx_volume: float = 0.5

var audio_components: Array[CharacterAudio] = []

## TODO: Both deprecated! Remove after Wwise migration.
var sfx_player_template: PackedScene = preload('res://objects/audio/sfx_player.tscn')
var music_player_template: PackedScene = preload('res://objects/audio/music_player.tscn')

var wwise_audio_listener_template: PackedScene = preload('res://objects/audio/wwise_audio_listener.tscn')
var wwise_sound_bank_template: PackedScene = preload('res://objects/audio/wwise_sound_bank.tscn')

## TODO: Both deprecated! Remove after Wwise migration.
var sfx_player: SFXPlayer
var music_player: MusicPlayer

var wwise_audio_listener: AkListener2D
var wwise_sound_bank: AkBank


## TODO: Deprecated! Remove/Replace after Wwise migration.
func _ready() -> void:
	sfx_player = sfx_player_template.instantiate()
	music_player = music_player_template.instantiate()

	wwise_audio_listener = wwise_audio_listener_template.instantiate()
	wwise_sound_bank = wwise_sound_bank_template.instantiate()

	add_child(sfx_player)
	add_child(music_player)

	add_child(wwise_audio_listener)
	add_child(wwise_sound_bank)


func _process(_delta: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index('Master'), master_volume
	)
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index('Music'), music_volume
	)
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index('SFX'), sfx_volume
	)


func post_event(event: Event, source: Node = null) -> void:
	var event_name: String = _event_name(event)
	if event_name:
		Wwise.post_event(event_name, source if source else self)


func set_state(state: State) -> void:
	var state_group: String = _state(state)['group']
	var state_value: String = _state(state)['value']
	if state_group:
		Wwise.set_state(state_group, state_value)


func set_switch(switch: Switch, source: Node = null) -> void:
	var switch_group: String = _switch(switch)['group']
	var switch_value: String = _switch(switch)['value']
	if switch_group:
		Wwise.set_switch(switch_group, switch_value, source if source else self)


## TODO: Deprecated! Replaced with the functions above.
func play_sfx(clip: Clip, volume: float = 0.5) -> void:
	var clip_name: StringName = _pick_clip(clip)
	if clip_name:
		sfx_player.play_clip(clip_name, volume)


## TODO: Deprecated! Replaced with the functions above.
func play_music(track: Track, volume: float = 0.5) -> void:
	var track_name: StringName = _pick_track(track)
	if track_name:
		music_player.play_clip(track_name, volume)


## TODO: Deprecated! Replaced with the functions above.
func stop_music() -> void:
	music_player.stop()


func _event_name(event: Event) -> String:
	match event:
		Event.ATTACK_BC:
			return 'Attack_BC'
		Event.ATTACK_BHC:
			return 'Attack_BHC'
		Event.ATTACK_EC:
			return 'Attack_EC'
		Event.ATTACK_GC:
			return 'Attack_GC'
		Event.ATTACK_NC:
			return 'Attack_NC'
		Event.ATTACK_PC:
			return 'Attack_PC'
		Event.ATTACK_RC:
			return 'Attack_RC'
		Event.ATTACK_SC:
			return 'Attack_SC'
		Event.SKILL_BC_CHARGE:
			return 'SKill_BC_Charge'
		Event.SKILL_BC_SLAM:
			return 'SKill_BC_Slam'
		Event.SKILL_BHC:
			return 'SKill_BHC'
		Event.SKILL_EC:
			return 'SKill_EC'
		Event.SKILL_GC:
			return 'SKill_GC'
		Event.SKILL_NC:
			return 'SKill_NC'
		Event.SKILL_PC:
			return 'SKill_PC'
		Event.SKILL_RC:
			return 'SKill_RC'
		Event.SKILL_SC:
			return 'SKill_SC'
	
	return ''


func _state(state: State) -> Dictionary[String, String]:
	match state:
		State.INTRO:
			return {
				'group': 'Music_States',
				'value': 'Intro'
			}
		State.COMBAT:
			return {
				'group': 'Music_States',
				'value': 'Combat'
			}
		State.PRECOMBAT:
			return {
				'group': 'Music_States',
				'value': 'PreCombat'
			}
	
	return {
		'group': '',
		'value': ''
	}


func _switch(switch: Switch) -> Dictionary[String, String]:
	match switch:
		Switch.NORMAL:
			return {
				'group': 'Effect_Switches',
				'value': 'Normal'
			}
		Switch.SMASHED:
			return {
				'group': 'Effect_Switches',
				'value': 'Smashed'
			}
	
	return {
		'group': '',
		'value': ''
	}


## TODO: Deprecated! Replaced with the functions above.
func _pick_clip(clip: Clip) -> StringName:
	match clip:
		Clip.BC_ABILITY_CHARGE:
			return &'BC Ability Charge'
		Clip.BC_ABILITY_SLAM:
			return &'BC Ability Slam'
		Clip.BC_ATTACK:
			return &'BC Attack'
		Clip.BHC_ABILITY:
			return &'BHC Ability'
		Clip.BHC_ATTACK:
			return &'BHC Attack'
		Clip.EC_ABILITY:
			return &'EC Ability'
		Clip.EC_ATTACK:
			return &'EC Attack'
		Clip.EC_ATTACK_NO_FUSE:
			return &'EC Attack No Fuse'
		Clip.GC_ABILITY:
			return &'GC Ability'
		Clip.GC_ATTACK:
			return &'GC Attack'
		Clip.PC_ABILITY:
			return &'PC Ability'
		Clip.PC_ATTACK:
			return &'PC Attack'
		Clip.RC_ABILITY:
			return &'RC Ability'
		Clip.RC_ATTACK:
			return &'RC Attack'
		Clip.SC_ABILITY:
			return &'SC Ability'
		Clip.SC_ATTACK:
			return &'SC Attack'
		Clip.NC_ABILITY:
			return &'NC Ability'
		Clip.NC_ATTACK:
			return &'NC Attack'
		Clip.EAT_CRUNCH:
			return &'Eat Crunch'
		Clip.UI_BUTTON:
			return &'UI Button'
	
	return &''


## TODO: Deprecated! Replaced with the functions above.
func _pick_track(track: Track) -> StringName:
	match track:
		Track.TRACK1:
			return &'Track 1'
		Track.TRACK2:
			return &'Track 2'
	
	return &''
