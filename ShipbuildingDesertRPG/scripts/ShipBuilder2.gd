extends Area2D
class_name ShipBuilder2

@export var nodeObject: PackedScene
@export var edgeObject: PackedScene
@export var wheelObject: PackedScene

var selectedNode: ShipObject2 = null

var shipNodes: Array = Array()
var shipEdges: Array = Array()

func _ready():
	$CollisionShape2D.shape.size = get_viewport_rect().size
	$CollisionShape2D.position = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag") && selectedNode != null:
		if selectedNode is ShipNode2:
			CreateNode()

func _input(event):
	if event.is_action_pressed("ship_select_node"):
		
	if event.is_action_released("ship_drag") && selectedNode != null:
		ReleaseNode()

func _process(delta):
	if selectedNode != null:
		MoveNode(get_global_mouse_position())

func DeleteEdge(edge: ShipEdge):
	shipEdges.erase(edge.opposite)
	shipEdges.erase(edge)

func CreateNode():
	var new_node = nodeObject.instantiate()
	new_node.position = get_global_mouse_position()
	add_child(new_node)
	shipNodes.append(new_node)

func ReleaseNode():
	MoveNode(selectedNode.position)
	selectedNode = null

func MoveNode(pos: Vector2):
	selectedNode.position = ClampNode(pos)
	#UpdateNodeEdgesSimple(selectedNode)

func DeleteNode(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.Delete()
	shipNodes.erase(node)

func ClampNode(pos: Vector2) -> Vector2:
	var x = $CollisionShape2D.position.x
	var y = $CollisionShape2D.position.y
	var w = $CollisionShape2D.shape.size.x/2
	var h = $CollisionShape2D.shape.size.y/2
	return Vector2(clamp(pos.x, x - w, x + w), clamp(pos.y, y - h, y + h))
