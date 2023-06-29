extends Line2D
class_name ShipEdge

var nodeA: ShipNode = null
var nodeB: ShipNode = null

var opposite: ShipEdge = null

func Update():
	if nodeA != null && nodeB != null:
		points = [nodeA.position, nodeB.position]
		opposite.points = [nodeA.opposite.position, nodeB.opposite.position]
		UpdateCollision()
		opposite.UpdateCollision()
	elif nodeA != null:
		points = [nodeA.position, get_global_mouse_position()]
		opposite.points = [nodeA.opposite.position, (get_parent() as ShipBuilder).GetOppositePoint(get_global_mouse_position())]
		
func UpdateSimple():
	if nodeA != null && nodeB != null:
		points = [nodeA.position, nodeB.position]
		opposite.points = [nodeA.opposite.position, nodeB.opposite.position]
	elif nodeA != null:
		points = [nodeA.position, get_global_mouse_position()]
		opposite.points = [nodeA.opposite.position, (get_parent() as ShipBuilder).GetOppositePoint(get_global_mouse_position())]

func UpdateCollision():
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$Area2D.add_child(new_shape)
		var rect = RectangleShape2D.new()
		new_shape.position = (points[i] + points[i + 1]) / 2
		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, 10)
		new_shape.shape = rect

func _process(delta):
	if nodeA != null && nodeB == null:
		points[1] = get_global_mouse_position()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_released("ship_delete"):
		Delete()

func Delete():
	opposite.Delete()
	(get_parent() as ShipBuilder).DeleteEdge(self)
	queue_free()
