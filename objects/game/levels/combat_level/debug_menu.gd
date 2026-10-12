extends CanvasLayer


func _ready() -> void:
	hide()
	setup()


func setup() -> void:
	$PanelContainer/VBoxContainer/KillAllyFront.pressed.connect(_on_kill_ally.bind(0))
	$PanelContainer/VBoxContainer/KillAlly2nd.pressed.connect(_on_kill_ally.bind(1))
	$PanelContainer/VBoxContainer/KillAlly3rd.pressed.connect(_on_kill_ally.bind(2))
	$PanelContainer/VBoxContainer/KillAlly4th.pressed.connect(_on_kill_ally.bind(3))
	
	$PanelContainer/VBoxContainer/KillEnemyFront.pressed.connect(_on_kill_enemy.bind(0))
	$PanelContainer/VBoxContainer/KillEnemy2nd.pressed.connect(_on_kill_enemy.bind(1))
	$PanelContainer/VBoxContainer/KillEnemy3rd.pressed.connect(_on_kill_enemy.bind(2))
	$PanelContainer/VBoxContainer/KillEnemy4th.pressed.connect(_on_kill_enemy.bind(3))
	
	$PanelContainer/VBoxContainer/LoseBattle.pressed.connect(_on_lose_battle)
	$PanelContainer/VBoxContainer/WinBattle.pressed.connect(_on_win_battle)

	$PanelContainer/VBoxContainer/RollCredits.pressed.connect(
		TransitionLayer.transition_simple_fade.bind(TransitionLayer.credits)
	)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("enter_debug"):
		visible = !visible


func _on_kill_ally(index: int) -> void:
	if index >= Game.combat.characters.allies.size():
		return
	
	var ally: Character = Game.combat.characters.allies[index]
	
	while not ally.state.knocked_out:
		ally.state.take_damage(999)
	
	if ally == Game.combat.turn_tracker.current_character:
		Game.combat.turn_tracker.end_current_turn()


func _on_kill_enemy(index: int) -> void:
	if index >= Game.combat.characters.enemies.size():
		return
	
	var enemy: Character = Game.combat.characters.enemies[index]
	
	while not enemy.state.knocked_out:
		enemy.state.take_damage(999)
	
	if enemy == Game.combat.turn_tracker.current_character:
		Game.combat.turn_tracker.end_current_turn()


func _on_lose_battle() -> void:
	while Game.combat.characters.allies.size():
		_on_kill_ally(-1)


func _on_win_battle() -> void:
	while Game.combat.characters.enemies.size():
		_on_kill_enemy(-1)
