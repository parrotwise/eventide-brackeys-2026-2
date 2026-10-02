extends Control


var c1_sprite: Sprite2D:
	get: return $CharAnchors/C1Anchor/C1Sprite
var c2_sprite: Sprite2D:
	get: return $CharAnchors/C2Anchor/C2Sprite
var c3_sprite: Sprite2D:
	get: return $CharAnchors/C3Anchor/C3Sprite
var c4_sprite: Sprite2D:
	get: return $CharAnchors/C4Anchor/C4Sprite

var char_sprites: Array[Sprite2D]:
	get: return [c1_sprite, c2_sprite, c3_sprite, c4_sprite]


func _ready() -> void:
	if Game.allies.size() <= 1:
		## Shouldn't be in this scene, go to...uh...some other scene
		TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)
	
	elif Game.allies.size() == 2:
		c2_sprite.texture = Game.allies[0].silhouette
		c2_sprite.show()
		c3_sprite.texture = Game.allies[1].silhouette
		c3_sprite.show()
	
	else:
		for i: int in char_sprites.size():
			if i < Game.allies.size():
				char_sprites[i].texture = Game.allies[i].silhouette
				char_sprites[i].show()
			else:
				char_sprites[i].hide()
	
	await get_tree().create_timer(7).timeout
	TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)
