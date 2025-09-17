extends Area2D

@export var item_type: String = "golden_axe"
var player_nearby: bool = false

func _ready():
	add_to_group("items")
	add_to_group("golden_axes")
	
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.modulate = Color.GOLD
		
	
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property($AnimatedSprite2D, "modulate", Color.YELLOW, 1.0)
		tween.tween_property($AnimatedSprite2D, "modulate", Color.GOLD, 1.0)

		var shimmer = create_tween()
		shimmer.set_loops()
		shimmer.tween_property($AnimatedSprite2D, "scale", Vector2(0.038, 0.034), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		shimmer.tween_property($AnimatedSprite2D, "scale", Vector2(0.088, 0.084), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	
	
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_despawn_timer_timeout)
	add_child(timer)
	timer.start()

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("attack"):
		pickup_item()

func _on_area_entered(area):
	if area != null and is_instance_valid(area) and area.is_in_group("player"):
		player_nearby = true

func _on_area_exited(area):
	if area != null and is_instance_valid(area) and area.is_in_group("player"):
		player_nearby = false

func pickup_item():
	
	get_parent().call("_on_golden_axe_picked_up")
	queue_free()

func _on_despawn_timer_timeout():
	print("Golden axe disappeared...")
	queue_free()
