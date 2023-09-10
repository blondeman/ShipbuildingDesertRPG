extends CharacterBody2D

var directions = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]

var speed: int = 100
var inputDirection: Vector2
var cardinalDirection: int

func _process(delta):
	inputDirection = Vector2.ZERO
	
	if Input.is_action_pressed("up"): inputDirection.y -= 1
	if Input.is_action_pressed("down"): inputDirection.y += 1
	if Input.is_action_pressed("left"): inputDirection.x -= 1
	if Input.is_action_pressed("right"): inputDirection.x += 1
	
	SetAnimation()

func _physics_process(delta):
	#velocity = inputDirection.normalized() * Vector2(1,0.5) * speed
	move_and_collide(inputDirection.normalized() * Vector2(1,0.5) * speed * delta)

func SetAnimation():
	if inputDirection == Vector2.ZERO: 
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = cardinalDirection
		return
	
	var angle: float = atan2( inputDirection.y, inputDirection.x );
	cardinalDirection = roundi( 8 * angle / (2*PI) + 8 ) % 8;
	
	$AnimatedSprite2D.play("characterRun-"+directions[cardinalDirection])
