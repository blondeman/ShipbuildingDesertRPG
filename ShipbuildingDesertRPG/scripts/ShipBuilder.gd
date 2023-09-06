extends Area2D
class_name ShipBuilder

var shipNodeScene = preload("res://scenes/ship_node.tscn")
var shipEdgeScene = preload("res://scenes/ship_edge.tscn")

var selectedNode: ShipNode = null

var shipNodes: Array = Array() #[front, end, node1 top, node1 bot, node2 top, node2 bot, ...]
var shipEdges: Array = Array() #[edgeA, edgeB, ...]

@export var camera: Camera2D
@export var middleWidth: int = 30
@export var zonePadding: int = 100

func _ready():
	SetZonePadding()
	AddFrontBackNodes(-200, 200)
	AddNode(Vector2(0, GetMiddle()+100))
	AddEdge(shipNodes[0], shipNodes[2])
	AddEdge(shipNodes[2], shipNodes[1])
	UpdatePolygon()
	
func SetZonePadding():
	if camera==null:return
	var screenSize = get_viewport_rect().size
	$CollisionShape2D.position.x = camera.position.x
	$CollisionShape2D.position.y = camera.position.y
	$CollisionShape2D.shape.size.x = screenSize.x - 2 * zonePadding
	$CollisionShape2D.shape.size.y = screenSize.y - 2 * zonePadding
	
func AddFrontBackNodes(frontPos: int, backPos: int):
	var front = shipNodeScene.instantiate()
	front.position = Vector2(frontPos,GetMiddle())
	front.shipBuilder = self
	front.isMiddle = true
	add_child(front)
	var back = shipNodeScene.instantiate()
	back.position = Vector2(backPos,GetMiddle())
	back.shipBuilder = self
	back.isMiddle = true
	add_child(back)
	shipNodes.append_array([front, back])

func _input(event):
	if event.is_action_released("ship_drag") && selectedNode != null:
		ReleaseNode()
	if event.is_action_pressed("test"):
		SaveBuild()
	if event.is_action_pressed("test2"):
		LoadBuild()

func _process(delta):
	if selectedNode != null:
		if(selectedNode.isMiddle):
			selectedNode.position = ClampNodeMiddle(get_global_mouse_position())
			UpdateNodeEdgesSimple(selectedNode)
		else:
			var oppositeNode = GetOppositeNode(selectedNode)
			selectedNode.position = ClampNode(selectedNode, get_global_mouse_position())
			oppositeNode.position = ClampNode(oppositeNode, GetOppositePoint(get_global_mouse_position()))
			UpdateNodeEdgesSimple(selectedNode)
			UpdateNodeEdgesSimple(oppositeNode)
		
		UpdatePolygon()

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
		if edge.HasNode(node):
			edge.UpdateCollision()

func UpdateNodeEdgesSimple(node: ShipNode):
	for edge in shipEdges:
		if edge.HasNode(node):
			edge.Update()

func SplitEdge(edge: ShipEdge):
	if selectedNode!=null:return
	
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

func IsEdgeTop(edge: ShipEdge) -> bool:
	if !edge.nodeA.isMiddle:
		return IsNodeTop(edge.nodeA)
	else:
		return IsNodeTop(edge.nodeB)

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
	
	var oldEdge = null
	
	for edge in shipEdges:
		if edge.nodeB == node:
			edgeA = edge
			edgeB = GetOppositeEdge(edge)
		if edge.nodeA == node:
			nodeA = edge.nodeB
			nodeB = GetOppositeEdge(edge).nodeB
			oldEdge = edge
	
	edgeA.nodeB = nodeA
	edgeB.nodeB = nodeB
	
	var oppositeNode = GetOppositeNode(node)
	shipNodes.erase(node)
	node.queue_free()
	shipNodes.erase(oppositeNode)
	oppositeNode.queue_free()
	
	edgeA.UpdateCollision()
	edgeB.UpdateCollision()
	
	DeleteEdge(oldEdge)

func ReleaseNode():
	if(selectedNode.isMiddle):
		selectedNode.position = ClampNodeMiddle(selectedNode.position)
		UpdateNodeEdges(selectedNode)
	else:
		selectedNode.position = ClampPosition(selectedNode.position)
		UpdateNodeEdges(selectedNode)
		GetOppositeNode(selectedNode).position = ClampPosition(GetOppositePoint(selectedNode.position))
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

func ClampNode(node: ShipNode, pos: Vector2) -> Vector2:
	var x = $CollisionShape2D.position.x
	var y = $CollisionShape2D.position.y
	var w = $CollisionShape2D.shape.size.x/2
	var h = $CollisionShape2D.shape.size.y/2
	
	if IsNodeTop(node):
		return Vector2(clamp(pos.x, x - w, x + w), clamp(pos.y, y + middleWidth, y + h))
	else:
		return Vector2(clamp(pos.x, x - w, x + w), clamp(pos.y, y - h, y - middleWidth))

func ClampNodeMiddle(pos: Vector2) -> Vector2:
	var x = $CollisionShape2D.position.x
	var y = $CollisionShape2D.position.y
	var w = $CollisionShape2D.shape.size.x/2
	return Vector2(clamp(pos.x, x - w, x + w), y)

func GetOppositeNode(node: ShipNode) -> ShipNode:
	if(node.isMiddle): return node
	var pos: int = shipNodes.find(node)
	if(pos%2==0):
		return shipNodes[pos+1]
	else:
		return shipNodes[pos-1]

func IsNodeTop(node: ShipNode) -> bool:
	return shipNodes.find(node)%2==0

#POLYGON FUNCTION

func UpdatePolygon():
	var startNode: ShipNode = shipNodes[0]
	var currentNode: ShipNode = GetNextNode(startNode, null)
	var previousNode: ShipNode = startNode
	
	var nodes: Array = []
	nodes.append(startNode.position)
	
	while currentNode!=startNode:
		nodes.append(currentNode.position)
		var nextNode = GetNextNode(currentNode, previousNode)
		previousNode = currentNode
		currentNode = nextNode
	
	$Polygon2D.polygon = nodes

func GetNextNode(node: ShipNode, previousNode: ShipNode) -> ShipNode:
	if(previousNode==null): return GetNodeEdges(node)[0].GetOppositeNode(node)
	
	var edges = GetNodeEdges(node)
	if edges[0].HasNode(previousNode):
		return edges[1].GetOppositeNode(node)
	else:
		return edges[0].GetOppositeNode(node)
	
	return null

func GetNodeEdges(node: ShipNode) -> Array:
	var edges = Array()
	for edge in shipEdges:
		if edge.HasNode(node):
			edges.append(edge)
	return edges

#GENERAL FUNCTIONS
	
func ClampPosition(pos: Vector2) -> Vector2:
	var x = $CollisionShape2D.position.x
	var y = $CollisionShape2D.position.y
	var w = $CollisionShape2D.shape.size.x/2
	var h = $CollisionShape2D.shape.size.y/2
	return Vector2(clamp(pos.x, x - w, x + w), clamp(pos.y, y - h, y + h))

	
func GetMiddle() -> int:
	return $CollisionShape2D.position.y

func GetOppositePoint(position: Vector2) -> Vector2:
	return Vector2(position.x, GetMiddle() - position.y + GetMiddle())

#BUILD FUNCTIONS

func SaveBuild():
	var nodes = []
	var edges = []
	
	for node in shipNodes:
		if(IsNodeTop(node) || node.isMiddle):
			nodes.append(node.position.x)
			nodes.append(node.position.y)
	for edge in shipEdges:
		if(IsEdgeTop(edge)):
			edges.append(shipNodes.find(edge.nodeA))
			edges.append(shipNodes.find(edge.nodeB))
	
	var json = {
		"nodes":nodes,
		"edges":edges
		}
	var file = FileAccess.open("user://ship_1.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(json))

func LoadBuild():
	ClearBuild()
	var file = FileAccess.open("user://ship_1.dat", FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	
	var nodes = json.nodes
	var edges = json.edges
	
	AddFrontBackNodes(nodes[0], nodes[2])
	
	for i in range(2, nodes.size()/2):
		var x = nodes[i*2]
		var y = nodes[i*2+1]
		AddNode(Vector2(x,y))
		
	for i in range(0, edges.size()/2):
		var nodeA = shipNodes[edges[i*2]]
		var nodeB = shipNodes[edges[i*2+1]]
		AddEdge(nodeA, nodeB)
		
	UpdatePolygon()

func ClearBuild():
	for edge in shipEdges:
		edge.queue_free()
	shipEdges.clear()
	for node in shipNodes:
		node.queue_free()
	shipNodes.clear()
