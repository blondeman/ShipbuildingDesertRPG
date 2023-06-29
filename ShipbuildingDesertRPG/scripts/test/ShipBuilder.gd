extends Area2D
class_name ShipBuilder

var selectedMenuItem: ShipMenuItem = null
var selectedNode: ShipNode = null
var selectedEdge: ShipEdge = null

var shipNodes: Array = Array()
var shipEdges: Array = Array()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ship_drag") && selectedMenuItem != null:
		if selectedMenuItem.itemType == ShipMenuItem.ITEM_TYPE.NODE:
			CreateNode()

func _input(event):
	if event.is_action_released("ship_drag") && selectedNode != null:
		ReleaseNode()

func _process(delta):
	if selectedNode != null:
		selectedNode.position = ClampNode(get_global_mouse_position())
		selectedNode.opposite.position = ClampNode(GetOppositePoint(get_global_mouse_position()))
		UpdateNodeEdgesSimple(selectedNode)
		UpdateNodeEdgesSimple(selectedNode.opposite)

#SELECT FUNCTIONS

func SelectItem(item: ShipMenuItem):
	if selectedEdge != null || selectedNode != null:
		return
	
	if item == selectedMenuItem:
		selectedMenuItem = null
	else:
		selectedMenuItem = item

func SelectNode(node: ShipNode):
	if selectedMenuItem == null:
		selectedNode = node
	elif selectedMenuItem.itemType == ShipMenuItem.ITEM_TYPE.EDGE:
		CreateEdge(node)

#EDGE FUNCTIONS

func CreateEdge(node: ShipNode):
	if selectedEdge == null:
		var new_edge = selectedMenuItem.node.instantiate()
		add_child(new_edge)
		shipEdges.append(new_edge)
		new_edge.nodeA = node
		
		var new_edge_opposite = selectedMenuItem.node.instantiate()
		add_child(new_edge_opposite)
		shipEdges.append(new_edge_opposite)
		new_edge_opposite.nodeA = node.opposite
		
		new_edge.opposite = new_edge_opposite
		new_edge_opposite.opposite = new_edge
		
		selectedEdge = new_edge
		selectedEdge.Update()
	else:
		selectedEdge.nodeB = node
		selectedEdge.Update()
		#selectedMenuItem = null
		selectedEdge = null

func UpdateNodeEdges(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.Update()
			
func UpdateNodeEdgesSimple(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.UpdateSimple()

func DeleteEdge(edge: ShipEdge):
	shipEdges.erase(edge.opposite)
	shipEdges.erase(edge)

#NODE FUNCTIONS

func CreateNode():
	var new_node = selectedMenuItem.node.instantiate()
	new_node.position = get_global_mouse_position()
	add_child(new_node)
	shipNodes.append(new_node)
	
	var new_node_opposite = selectedMenuItem.node.instantiate()
	new_node_opposite.position = GetOppositePoint(get_global_mouse_position())
	add_child(new_node_opposite)
	shipNodes.append(new_node_opposite)
	
	new_node.opposite = new_node_opposite
	new_node_opposite.opposite = new_node
	
	#selectedMenuItem = null

func DeleteNode(node: ShipNode):
	for edge in shipEdges:
		if edge.nodeA == node || edge.nodeB == node:
			edge.Delete()
	shipNodes.erase(node)

func ReleaseNode():
	selectedNode.position = ClampNode(selectedNode.position)
	UpdateNodeEdges(selectedNode)
	selectedNode = null

func ClampNode(pos: Vector2) -> Vector2:
	var x = $CollisionShape2D.position.x
	var y = $CollisionShape2D.position.y
	var w = $CollisionShape2D.shape.size.x/2
	var h = $CollisionShape2D.shape.size.y/2
	return Vector2(clamp(pos.x, x - w, x + w), clamp(pos.y, y - h, y + h))

func GetOppositePoint(pos: Vector2) -> Vector2:
	return Vector2(pos.x, $CollisionShape2D.position.y + ($CollisionShape2D.position.y - pos.y))
