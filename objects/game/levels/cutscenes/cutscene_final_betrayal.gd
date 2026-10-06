extends Control


var c1_sprite: Sprite2D:
	get: return $CharAnchors/C1Anchor/C1Sprite
var c2_sprite: Sprite2D:
	get: return $CharAnchors/C2Anchor/C2Sprite

var char_sprites: Array[Sprite2D]:
	get: return [c1_sprite, c2_sprite]


func _ready() -> void:
	if Game.allies.size() <= 1:
		## Shouldn't be in this scene, go to...uh...some other scene
		TransitionLayer.transition_simple_fade(TransitionLayer.loadout_level)
	
	else:
		Game.allies.shuffle()
		for i: int in char_sprites.size():
			if i < Game.allies.size():
				var sprite1: Sprite2D = char_sprites[i]

				sprite1.texture = Game.allies[i].silhouette
				sprite1.frame = 0
				sprite1.show()

				var sprite2: Sprite2D = sprite1.duplicate()
				sprite2.frame = 1
				sprite2.show()

				sprite1.get_parent().add_child(sprite2)

				sprite1.modulate = Color.WHITE
				sprite2.modulate = Color.TRANSPARENT

				var tween: Tween = get_tree().create_tween() \
				                             .set_ease(Tween.EASE_OUT_IN) \
											 .set_trans(Tween.TRANS_LINEAR)

				tween.tween_property(sprite1, ^'modulate', Color.WHITE, 3)
				tween.parallel() \
				     .tween_property(sprite2, ^'modulate', Color.TRANSPARENT, 3)

				tween.tween_property(sprite1, ^'modulate', Color.TRANSPARENT, 1)
				tween.parallel() \
				     .tween_property(sprite2, ^'modulate', Color.WHITE, 1)

			else:
				char_sprites[i].hide()
	
	await get_tree().create_timer(10).timeout
	TransitionLayer.transition_simple_fade(TransitionLayer.credits)
