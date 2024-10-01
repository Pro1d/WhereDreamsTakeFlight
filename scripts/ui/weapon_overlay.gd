class_name WeaponOverlay
extends Control

const REPAIR := -1
#signal repaired()
signal weapon_picked(index: int) # -1 for repair
signal slot_picked(index: int)

@onready var weapon_buttons : Array[Button] = [%Weapon1Button, %Weapon2Button]
@onready var slot_buttons : Array[Button] = [%SlotButton1, %SlotButton2, %SlotButton3]
@onready var weapon_container := %WeaponContainer as Control
@onready var slot_container := %SlotContainer as Control

var last_weapon_picked := REPAIR
var last_slot_selected := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	(%RecycleButton as Button).tooltip_text += "(+%d)" % [Config.REPAIR_HEALTH]
	(%RecycleButton as Button).pressed.connect(func() -> void:
		last_weapon_picked = -1
		weapon_picked.emit(last_weapon_picked))
	for i in range(weapon_buttons.size()):
		weapon_buttons[i].pressed.connect(
			(func(idx: int) -> void:
				last_weapon_picked = idx
				weapon_picked.emit(last_weapon_picked)).bind(i)
		)
	for i in range(slot_buttons.size()):
		slot_buttons[i].pressed.connect(
			(func(idx: int) -> void:
				last_slot_selected = idx
				slot_picked.emit(last_slot_selected)).bind(i)
		)

func show_weapon_options(
	name1: String, name2: String,
	desc1: String, desc2: String,
	allow_repair: bool
) -> void:
	weapon_container.show()
	slot_container.hide()
	weapon_buttons[0].text = "Pick " + name1
	weapon_buttons[1].text = "Pick " + name2
	(weapon_buttons[0].get_child(0) as Label).text = desc1
	(weapon_buttons[1].get_child(0) as Label).text = desc2
	(%RecycleButton as Button).disabled = not allow_repair

func show_slots(slots: Array[String]) -> void:
	weapon_container.hide()
	slot_container.show()
	(%RepairLabel as Control).hide()
	slot_buttons[0].text = "Put here" if slots[0] == "" else "Replace " + slots[0]
	slot_buttons[1].text = "Put here" if slots[1] == "" else "Replace " + slots[1]
	slot_buttons[2].text = "Put here" if slots[2] == "" else "Replace " + slots[2]
