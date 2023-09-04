extends Line2D
class_name ShipEdge

var nodeA: ShipNode = null
var nodeB: ShipNode = null

func Update():
	if nodeA != null && nodeB != null:
		points = [nodeA.position, nodeB.position]
		UpdateCollision()

func UpdateSimple():
	if nodeA != null && nodeB != null:
		points = [nodeA.position, nodeB.position]

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
