extends Control


var ally1_rect: TextureRect:
	get: return $TeamAnchors/AlliesAnchor/Eyes/Eyes1
var ally2_rect: TextureRect:
	get: return $TeamAnchors/AlliesAnchor/Eyes/Eyes2
var enemy1_rect: TextureRect:
	get: return $TeamAnchors/EnemiesAnchor/Eyes/Eyes1
var enemy2_rect: TextureRect:
	get: return $TeamAnchors/EnemiesAnchor/Eyes/Eyes2


func _ready() -> void:
	Game.mutiny()
	
	if Game.allies:
		ally1_rect.texture = Game.allies[0].eyes
		ally1_rect.show()
	else:
		ally1_rect.hide()
	
	if Game.allies.size() > 1:
		ally2_rect.texture = Game.allies[1].eyes
		ally2_rect.show()
	else:
		ally2_rect.hide()
	
	if Game.enemies:
		enemy1_rect.texture = Game.enemies[0].eyes
		enemy1_rect.show()
	else:
		enemy1_rect.hide()
	
	if Game.enemies.size() > 1:
		enemy2_rect.texture = Game.enemies[1].eyes
		enemy2_rect.show()
	else:
		enemy2_rect.hide()
	
	await get_tree().create_timer(7).timeout
	TransitionLayer.transition_simple_fade(TransitionLayer.combat_level)
