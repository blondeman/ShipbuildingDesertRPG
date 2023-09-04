extends Area2D
class_name ShipNode

var shipBuilder: ShipBuilder = null
var isMiddle: bool = false

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag"):
		shipBuilder.SelectNode(self)
	if event.is_action_released("ship_delete"):
		shipBuilder.DeleteNode(self)
