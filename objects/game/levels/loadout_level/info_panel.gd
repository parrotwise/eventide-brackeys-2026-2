class_name InfoPanel
extends VBoxContainer


var id_label: RichTextLabel:
	get: return $IDLabel
var blurb_label: RichTextLabel:
	get: return $BlurbLabel
var passive_section: HBoxContainer:
	get: return $PassiveSection
var passive_image: TextureRect:
	get: return $PassiveSection/Image
var passive_title: RichTextLabel:
	get: return $PassiveSection/Text/Title
var passive_description: RichTextLabel:
	get: return $PassiveSection/Text/Description
var skill_section: HBoxContainer:
	get: return $SkillSection
var skill_image: TextureRect:
	get: return $SkillSection/Image
var skill_title: RichTextLabel:
	get: return $SkillSection/Text/Title
var skill_description: RichTextLabel:
	get: return $SkillSection/Text/Description
var equipment_section: VBoxContainer:
	get: return $EquipmentSection
var equipment_buttons: HBoxContainer:
	get: return $EquipmentSection/Buttons

var selected: Character:
	get: return Game.loadout.selector.current_character


func refresh() -> void:
	if not is_instance_valid(selected):
		return
	
	for child: Node in get_children():
		child.hide()

	if selected.id:
		id_label.text = '[font_size=32]%s[/font_size]' % selected.id
		id_label.show()
	
	if selected.blurb:
		blurb_label.text = '[font_size=20]%s[/font_size]' % selected.blurb
		blurb_label.show()
	
	if selected.state.passive_status:
		passive_image.texture = selected.state.passive_status.passive_icon_normal

		passive_title.text = (
			'[font_size=24]%s[/font_size]' %
			'Passive Ability'
		)
		passive_description.text = (
			'[font_size=18]%s[/font_size]' %
			selected.state.passive_status.description
		)

		passive_section.show()
	
	if selected.actions.skills:
		skill_image.texture = selected.actions.skills[0].icon

		skill_title.text = (
			'[font_size=24]%s[/font_size]' %
			selected.actions.skills[0].name
		)
		skill_description.text = (
			'[font_size=18]%s[/font_size]' %
			selected.actions.skills[0].description
		)

		skill_section.show()
	
	if Game.inventories.get(selected.id):
		for child: Node in equipment_buttons.get_children():
			child.queue_free()

		for equipment: Equipment in Game.inventories[selected.id]:
			var button := Game.loadout.ui.equipment_button_template.instantiate() as EquipmentButton
			button.setup(equipment)

			equipment_buttons.add_child(button)
		
		equipment_section.show()
