extends Area2D
class_name ShipMenuItem

enum ITEM_TYPE {NODE, EDGE, WHEEL}

@export var itemType: ITEM_TYPE
@export var node: PackedScene

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag"):
		(get_parent() as ShipBuilder).SelectItem(self)
