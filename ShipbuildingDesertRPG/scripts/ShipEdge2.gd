extends ShipObject2
class_name ShipEdge2

var nodeA: ShipNode2 = null
var nodeB: ShipNode2 = null

func Update():
	if nodeA != null && nodeB != null:
		$Line2D.points = [nodeA.position, nodeB.position]
	elif nodeA != null:
		$Line2D.points = [nodeA.position, get_global_mouse_position()]

func UpdateCollision():
	for i in $Line2D.points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$Area2D.add_child(new_shape)
		var rect = RectangleShape2D.new()
		new_shape.position = ($Line2D.points[i] + $Line2D.points[i + 1]) / 2
		new_shape.rotation = $Line2D.points[i].direction_to($Line2D.points[i + 1]).angle()
		var length = $Line2D.points[i].distance_to($Line2D.points[i + 1])
		rect.extents = Vector2(length / 2, 10)
		new_shape.shape = rect

func _process(delta):
	if nodeA != null && nodeB == null:
		$Line2D.points[1] = get_global_mouse_position()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_released("ship_delete"):
		Delete()

func Delete():
	(get_parent() as ShipBuilder2).DeleteEdge(self)
	queue_free()
