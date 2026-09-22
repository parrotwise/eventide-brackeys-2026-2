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
			Game.inventories.has(selected.name)
			and (button.equipment in Game.inventories[selected.name])
		)

		if is_owned_by_selected:
			button.button.disabled = false
			button.button.button_pressed = true
		
		elif not button.button.button_pressed:
			button.button.disabled = false
		
		else:
			button.button.disabled = true
	
	if Game.inventories.has(selected.name) and (Game.inventories[selected.name].size() >= 2):
		for button: EquipmentButton in equipment_buttons:
			button.button.disabled = button.equipment not in Game.inventories[selected.name]
