extends Area2D

@export var speed: int = 400
var screen_size: Vector2

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	add_to_group("player")
	hide()

func _process(delta):
	var dir = Vector2.ZERO

	# Movement input
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
		$AnimatedSprite2D.animation = "right"
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
		$AnimatedSprite2D.animation = "right"
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
		$AnimatedSprite2D.animation = "up"
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
		$AnimatedSprite2D.animation = "up"
	
	
	if Input.is_action_just_pressed("attack"):
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.animation = "chop"
		print("Attack!")

	
	if dir.length() > 0:
		dir = dir.normalized() * speed
		if has_node("AnimatedSprite2D") and $AnimatedSprite2D.animation != "chop":
			$AnimatedSprite2D.play()
	else:
		if has_node("AnimatedSprite2D") and $AnimatedSprite2D.animation != "chop":
			$AnimatedSprite2D.stop()

	position += dir * delta
	position = Vector2(
		clamp(position.x, 0, screen_size.x),
		clamp(position.y, 0, screen_size.y)
	)

	
	if has_node("AnimatedSprite2D") and $AnimatedSprite2D.animation != "chop":
		if dir.x != 0:
			$AnimatedSprite2D.animation = "right"
			$AnimatedSprite2D.flip_h = dir.x < 0
		elif dir.y != 0:
			$AnimatedSprite2D.animation = "up"

func start(pos: Vector2):
	position = pos
	show()
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = false
