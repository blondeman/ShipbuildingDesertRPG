extends Line2D
class_name ShipEdge

var shipBuilder: ShipBuilder = null
var nodeA: ShipNode = null
var nodeB: ShipNode = null

func Update():
	if nodeA != null && nodeB != null:
		points = [nodeA.position, nodeB.position]
		$handle.position = GetMiddle()

func UpdateCollision():
	Update()
	SetCollision()

func SetCollision():
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$edge_collision.add_child(new_shape)
		var rect = RectangleShape2D.new()
		new_shape.position = (points[i] + points[i + 1]) / 2
		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, 10)
		new_shape.shape = rect

func GetMiddle() -> Vector2:
	return (nodeA.position + nodeB.position) / 2

func _on_handle_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag"):
		shipBuilder.SplitEdge(self)
