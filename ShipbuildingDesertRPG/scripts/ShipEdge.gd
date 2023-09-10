extends Line2D
class_name ShipEdge

var shipBuilder: ShipBuilder = null
var nodeA: ShipNode = null
var nodeB: ShipNode = null

var nodeVisibilityDistance: int = 50
var maxOpacityScale: int = 2 #a value of 3 means it will be at full 1/3 of the way there

func _process(delta):
	if get_global_mouse_position().distance_to($handle.position) <= nodeVisibilityDistance:
		$handle.visible = true
		var d = get_global_mouse_position().distance_to($handle.position)/nodeVisibilityDistance
		var t = -maxOpacityScale * d + maxOpacityScale
		$handle/Sprite2D.modulate.a = t
	else:
		$handle.visible = false

func GetOppositeNode(node: ShipNode) -> ShipNode:
	if nodeA == node:
		return nodeB
	else:
		return nodeA

func HasNode(node: ShipNode) -> bool:
	if nodeA == node || nodeB == node:
		return true
	return false

func Update():
	if nodeA != null && nodeB != null:
		points = [nodeA.position, nodeB.position]
		$handle.position = GetMiddle()

func UpdateCollision():
	Update()
	SetCollision()

func SetCollision():
	for child in $edge_collision.get_children(false):
		$edge_collision.remove_child(child)
	
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$edge_collision.add_child(new_shape)
		var rect = RectangleShape2D.new()
		new_shape.position = (points[i] + points[i + 1]) / 2
		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, width)
		new_shape.shape = rect

func GetMiddle() -> Vector2:
	return (nodeA.position + nodeB.position) / 2

func _on_handle_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag"):
		shipBuilder.SplitEdge(self)
