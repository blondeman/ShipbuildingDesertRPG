extends ShipObject2
class_name ShipNode2

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag"):
		(get_parent() as ShipBuilder2).SelectNode(self)
	if event.is_action_released("ship_delete"):
		Delete()

func Delete():
	(get_parent() as ShipBuilder2).DeleteNode(self)
	queue_free()
