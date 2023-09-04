extends Area2D
class_name ShipBuilder

var shipNodeScene = preload("res://scenes/test/ship_node.tscn")
var shipEdgeScene = preload("res://scenes/test/ship_edge.tscn")

var selectedNode: ShipNode = null

var shipNodes: Array = Array() #[front, end, node1 top, node1 bot, node2 top, node2 bot, ...]
var shipEdges: Array = Array()

func _ready():
	AddFrontBackNodes()
	AddNode(Vector2(400, GetMiddle()+100))
	AddEdge(shipNodes[0], shipNodes[2])
	AddEdge(shipNodes[0], shipNodes[3])
	AddEdge(shipNodes[1], shipNodes[2])
	AddEdge(shipNodes[1], shipNodes[3])
	
func AddFrontBackNodes():
	var front = shipNodeScene.instantiate()
	front.position = Vector2(200,GetMiddle())
	front.shipBuilder = self
	front.isMiddle = true
	add_child(front)
	var back = shipNodeScene.instantiate()
	back.position = Vector2(600,GetMiddle())
	back.shipBuilder = self
	back.isMiddle = true
	add_child(back)
	shipNodes.append_array([front, back])

func _input(event):
	if event.is_action_released("ship_drag") && selectedNode != null:
		ReleaseNode()

func _process(delta):
	if selectedNode != null:
		if(selectedNode.isMiddle):
			selectedNode.position = ClampNodeMiddle(get_global_mouse_position())
			UpdateNodeEdgesSimple(selectedNode)
		else:
			selectedNode.position = ClampNode(get_global_mouse_position())
			GetOppositeNode(selectedNode).position = GetOpposite(ClampNode(get_global_mouse_position()))
			UpdateNodeEdgesSimple(selectedNode)
			UpdateNodeEdgesSimple(GetOppositeNode(selectedNode))

#EDGE FUNCTIONS

func AddEdge(nodeA: ShipNode, nodeB: ShipNode):
	var edge = shipEdgeScene.instantiate()
	edge.nodeA = nodeA
	edge.nodeB = nodeB
	edge.Update()
	add_child(edge)
	shipEdges.append(edge)

func UpdateNodeEdges(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.Update()

func UpdateNodeEdgesSimple(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.UpdateSimple()

#func DeleteEdge(edge: ShipEdge):
#	shipEdges.erase(edge.opposite)
#	shipEdges.erase(edge)

#NODE FUNCTIONS

#func CreateNode():
#	var new_node = selectedMenuItem.node.instantiate()
#	new_node.position = get_global_mouse_position()
#	add_child(new_node)
#	shipNodes.append(new_node)
#
#	var new_node_opposite = selectedMenuItem.node.instantiate()
#	new_node_opposite.position = GetOppositePoint(get_global_mouse_position())
#	add_child(new_node_opposite)
#	shipNodes.append(new_node_opposite)
#
#	new_node.opposite = new_node_opposite
#	new_node_opposite.opposite = new_node
#
#	#selectedMenuItem = null

func SelectNode(node: ShipNode):
	selectedNode = node

func DeleteNode(node: ShipNode):
#	for edge in shipEdges:
#		if edge.nodeA == node || edge.nodeB == node:
#			edge.Delete()
	shipNodes.erase(node)

func ReleaseNode():
	if(selectedNode.isMiddle):
		selectedNode.position = ClampNodeMiddle(selectedNode.position)
		UpdateNodeEdges(selectedNode)
	else:
		selectedNode.position = ClampNode(selectedNode.position)
		UpdateNodeEdges(selectedNode)
		GetOppositeNode(selectedNode).position = ClampNode(GetOpposite(selectedNode.position))
		UpdateNodeEdges(GetOppositeNode(selectedNode))
		
	selectedNode = null

func AddNode(position: Vector2):
	var nodeA = shipNodeScene.instantiate()
	nodeA.position = position
	nodeA.shipBuilder = self
	add_child(nodeA)
	
	var nodeB = shipNodeScene.instantiate()
	nodeB.position = GetOpposite(position)
	nodeB.shipBuilder = self
	add_child(nodeB)
	
	if(position.y>GetMiddle()):
		shipNodes.append(nodeA)
		shipNodes.append(nodeB)
	else:
		shipNodes.append(nodeB)
		shipNodes.append(nodeA)
		
	print(nodeB.position)
	for i in shipNodes:
		print(i.position)

func ClampNode(pos: Vector2) -> Vector2:
	var x = $CollisionShape2D.position.x
	var y = $CollisionShape2D.position.y
	var w = $CollisionShape2D.shape.size.x/2
	var h = $CollisionShape2D.shape.size.y/2
	return Vector2(clamp(pos.x, x - w, x + w), clamp(pos.y, y - h, y + h))
	
func ClampNodeMiddle(pos: Vector2) -> Vector2:
	var x = $CollisionShape2D.position.x
	var y = $CollisionShape2D.position.y
	var w = $CollisionShape2D.shape.size.x/2
	var h = 0
	return Vector2(clamp(pos.x, x - w, x + w), clamp(pos.y, y - h, y + h))

func GetMiddle() -> int:
	return $CollisionShape2D.position.y

func GetOpposite(position: Vector2) -> Vector2:
	return Vector2(position.x, GetMiddle() - position.y + GetMiddle())

func GetOppositeNode(node: ShipNode) -> ShipNode:
	var pos: int = shipNodes.find(node)
	if(pos%2==0):
		return shipNodes[pos+1]
	else:
		return shipNodes[pos-1]

#func GetOppositePoint(pos: Vector2) -> Vector2:
#	return Vector2(pos.x, $CollisionShape2D.position.y + ($CollisionShape2D.position.y - pos.y))
