extends CharacterBody2D

@export var speed: float = 100.0
@export var item_drop_chance: float = 0.4
@export var item_scene: PackedScene

var screen_size: Vector2
var direction: Vector2
var direction_timer: float = 0.0
var change_direction_time: float = 2.0
var item_drop_timer: float = 0.0

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	add_to_group("npcs")
	choose_new_direction()

func _physics_process(delta):
	direction_timer -= delta
	item_drop_timer += delta
	
	if direction_timer <= 0:
		choose_new_direction()
	
	velocity = direction * speed
	move_and_slide()
	clamp_to_screen()
	
	if item_drop_timer >= 1.0:
		if randf() < item_drop_chance and item_scene:
			drop_item()
		item_drop_timer = 0.0
	
	update_animation()

func choose_new_direction():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	direction_timer = change_direction_time + randf_range(0, 1.0)

func clamp_to_screen():
	var margin = 20
	if position.x < margin:
		direction.x = abs(direction.x)
	elif position.x > screen_size.x - margin:
		direction.x = -abs(direction.x)
	
	if position.y < margin:
		direction.y = abs(direction.y)
	elif position.y > screen_size.y - margin:
		direction.y = -abs(direction.y)
	
	position.x = clamp(position.x, margin, screen_size.x - margin)
	position.y = clamp(position.y, margin, screen_size.y - margin)

func drop_item():
	var item = item_scene.instantiate()
	get_parent().add_child(item)
	item.global_position = global_position
	print("NPC dropped an item!")

func update_animation():
	if has_node("AnimatedSprite2D"):
		var sprite = $AnimatedSprite2D
		if direction.length() > 0:
			sprite.play()
			if abs(direction.x) > abs(direction.y):
				sprite.animation = "right"
				sprite.flip_h = direction.x < 0
			else:
				sprite.animation = "up"
		else:
			sprite.stop()
