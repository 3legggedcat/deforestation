extends RigidBody2D

signal mob_destroyed
var player_inside: bool = false

func _ready():
	add_to_group("mobs")
	
	# Keep mobs completely still
	rotation = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity_scale = 0
	freeze = true
	
	
	var main = get_tree().get_first_node_in_group("main")
	if main and main.has_method("_on_mob_destroyed"):
		mob_destroyed.connect(main._on_mob_destroyed)

	
	if has_node("AnimatedSprite2D") and $AnimatedSprite2D.sprite_frames:
		var anims = $AnimatedSprite2D.sprite_frames.get_animation_names()
		if anims.size() > 0:
			var index = randi_range(0, anims.size() - 1)
			$AnimatedSprite2D.animation = anims[index]
			$AnimatedSprite2D.play()

func _process(_delta):
	
	if player_inside and Input.is_action_just_pressed("attack"):
		
		mob_destroyed.emit()
		
		
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.modulate = Color.RED
		
		
		await get_tree().create_timer(0.1).timeout
		queue_free()

func _on_hit_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area != null and is_instance_valid(area) and area.is_in_group("player"):
		player_inside = true

func _on_hit_area_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area != null and is_instance_valid(area) and area.is_in_group("player"):
		player_inside = false
