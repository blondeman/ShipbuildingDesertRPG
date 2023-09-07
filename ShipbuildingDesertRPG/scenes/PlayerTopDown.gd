extends CharacterBody2D

var speed: int = 100
var inputDirection: Vector2

func _process(delta):
	inputDirection = Vector2.ZERO
	
	if Input.is_action_pressed("up"): inputDirection.y -= 1
	if Input.is_action_pressed("down"): inputDirection.y += 1
	if Input.is_action_pressed("left"): inputDirection.x -= 1
	if Input.is_action_pressed("right"): inputDirection.x += 1

func _physics_process(delta):
	velocity = inputDirection.normalized() * speed
	move_and_slide()
