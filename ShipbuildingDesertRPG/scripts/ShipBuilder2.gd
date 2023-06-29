extends Area2D

func _ready():
	$CollisionShape2D.shape.size = get_viewport_rect().size
	$CollisionShape2D.position = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)

func GetOppositePoint(pos: Vector2) -> Vector2:
	return Vector2(pos.x, $CollisionShape2D.position.y + ($CollisionShape2D.position.y - pos.y))
