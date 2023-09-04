extends Area2D
class_name ShipBuilder

var shipNodeScene = preload("res://scenes/test/ship_node.tscn")
var shipEdgeScene = preload("res://scenes/test/ship_edge.tscn")

var selectedNode: ShipNode = null

var shipNodes: Array = Array() #[front, end, node1 top, node1 bot, node2 top, node2 bot, ...]
var shipEdges: Array = Array() #[edgeA, edgeB, ...]

func _ready():
	AddFrontBackNodes()
	AddNode(Vector2(400, GetMiddle()+100))
	AddEdge(shipNodes[0], shipNodes[2])
	AddEdge(shipNodes[2], shipNodes[1])
	
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
			GetOppositeNode(selectedNode).position = GetOppositePoint(ClampNode(get_global_mouse_position()))
			UpdateNodeEdgesSimple(selectedNode)
			UpdateNodeEdgesSimple(GetOppositeNode(selectedNode))

#EDGE FUNCTIONS

func AddEdge(nodeA: ShipNode, nodeB: ShipNode):
	var edgeA = shipEdgeScene.instantiate()
	edgeA.nodeA = nodeA
	edgeA.nodeB = nodeB
	edgeA.shipBuilder = self
	edgeA.UpdateCollision()
	add_child(edgeA)
	shipEdges.append(edgeA)
	
	var edgeB = shipEdgeScene.instantiate()
	edgeB.nodeA = GetOppositeNode(nodeA)
	edgeB.nodeB = GetOppositeNode(nodeB)
	edgeB.shipBuilder = self
	edgeB.UpdateCollision()
	add_child(edgeB)
	shipEdges.append(edgeB)

func UpdateNodeEdges(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.UpdateCollision()

func UpdateNodeEdgesSimple(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.Update()

func SplitEdge(edge: ShipEdge):
	var node: ShipNode = AddNode(edge.GetMiddle())
	AddEdge(edge.nodeA, node)
	AddEdge(node, edge.nodeB)
	DeleteEdge(edge)
	
	selectedNode = node

func DeleteEdge(edge: ShipEdge):
	var oppositeEdge = GetOppositeEdge(edge)
	shipEdges.erase(edge)
	edge.queue_free()
	shipEdges.erase(oppositeEdge)
	oppositeEdge.queue_free()

func GetOppositeEdge(edge: ShipEdge) -> ShipEdge:
	var pos: int = shipEdges.find(edge)
	if(pos%2==0):
		return shipEdges[pos+1]
	else:
		return shipEdges[pos-1]

#NODE FUNCTIONS

func SelectNode(node: ShipNode):
	selectedNode = node

func DeleteNode(node: ShipNode):
	if node.isMiddle: return
	if shipNodes.size()<=4: return
	var nodeA = null
	var edgeA = null
	var nodeB = null
	var edgeB = null
	
	for edge in shipEdges:
		if edge.nodeB == node:
			edgeA = edge
			edgeB = GetOppositeEdge(edge)
		if edge.nodeA == node:
			nodeA = edge.nodeB
			nodeB = GetOppositeEdge(edge).nodeB
			DeleteEdge(edge)
	
	edgeA.nodeB = nodeA
	edgeB.nodeB = nodeB
	
	var oppositeNode = GetOppositeNode(node)
	shipNodes.erase(node)
	node.queue_free()
	shipNodes.erase(oppositeNode)
	oppositeNode.queue_free()
	
	edgeA.UpdateCollision()
	edgeB.UpdateCollision()

func ReleaseNode():
	if(selectedNode.isMiddle):
		selectedNode.position = ClampNodeMiddle(selectedNode.position)
		UpdateNodeEdges(selectedNode)
	else:
		selectedNode.position = ClampNode(selectedNode.position)
		UpdateNodeEdges(selectedNode)
		GetOppositeNode(selectedNode).position = ClampNode(GetOppositePoint(selectedNode.position))
		UpdateNodeEdges(GetOppositeNode(selectedNode))
		
	selectedNode = null

func AddNode(position: Vector2) -> ShipNode:
	var nodeA = shipNodeScene.instantiate()
	nodeA.position = position
	nodeA.shipBuilder = self
	add_child(nodeA)
	
	var nodeB = shipNodeScene.instantiate()
	nodeB.position = GetOppositePoint(position)
	nodeB.shipBuilder = self
	add_child(nodeB)
	
	if(position.y>GetMiddle()):
		shipNodes.append(nodeA)
		shipNodes.append(nodeB)
	else:
		shipNodes.append(nodeB)
		shipNodes.append(nodeA)
		
	return nodeA

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

func GetOppositePoint(position: Vector2) -> Vector2:
	return Vector2(position.x, GetMiddle() - position.y + GetMiddle())

func GetOppositeNode(node: ShipNode) -> ShipNode:
	if(node.isMiddle): return node
	var pos: int = shipNodes.find(node)
	if(pos%2==0):
		return shipNodes[pos+1]
	else:
		return shipNodes[pos-1]
