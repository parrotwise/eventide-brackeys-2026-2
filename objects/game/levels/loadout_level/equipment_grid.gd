class_name EquipmentGrid
extends GridContainer


var equipment_buttons: Array[EquipmentButton]:
	get: return Array(
		get_children(),
		TYPE_OBJECT, &'Control', EquipmentButton
	)

var selected: Character:
	get: return Game.loadout.selector.current_character


func reset() -> void:
	for button: EquipmentButton in equipment_buttons:
		remove_child(button)
		button.queue_free()
	
	for equipment: Equipment in Game.available_equipment:
		var button := Game.loadout.ui.equipment_button_template.instantiate() as EquipmentButton
		add_child(button)
		button.setup(equipment)
	
	refresh()


func refresh() -> void:
	if not is_instance_valid(selected):
		return

	for button: EquipmentButton in equipment_buttons:
		var is_owned_by_selected: bool = (
			button.equipment in Game.inventories.get(selected.name, [])
		)
		var is_owned_by_anyone: bool = Game.inventories.keys().any(
			func(ch): return button.equipment in Game.inventories[ch]
		)

		if is_owned_by_selected:
			button.set_equipped(true)
			button.set_responsive(true)
			button.set_pressed(true)
		
		elif is_owned_by_anyone:
			button.set_equipped(true)
			button.set_responsive(false)
			button.set_pressed(false)
		
		else:
			button.set_equipped(false)
			button.set_responsive(true)
			button.set_pressed(false)
	
	if Game.inventories.get(selected.name, []).size() >= 2:
		for button: EquipmentButton in equipment_buttons:
			button.set_responsive(
				button.equipment in Game.inventories[selected.name]
			)
