extends Area2D
class_name ShipNode

var opposite: ShipNode = null

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag"):
		(get_parent() as ShipBuilder).SelectNode(self)
	if event.is_action_released("ship_delete"):
		Delete()

func Delete():
	opposite.Delete()
	(get_parent() as ShipBuilder).DeleteNode(self)
	queue_free()
