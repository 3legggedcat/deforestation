extends Node

@export var mob_scene: PackedScene
@export var npc_scene: PackedScene
@export var item_scene: PackedScene
@export var mob_count: int = 10
@export var spawn_margin: int = 250
@export var game_time_limit: float = 30.0

var rng := RandomNumberGenerator.new()
var game_active: bool = false
var score: int = 0
var game_timer: float = 0.0
var npc_spawned: bool = false

func _ready():
	rng.randomize()
	$HUD.start_game.connect(_on_hud_start_game)

func _process(delta):
	if game_active:
		game_timer -= delta
		$HUD.update_timer(game_timer)
		check_game_conditions()

func _on_hud_start_game():
	new_game()

func new_game():
	score = 0
	game_timer = game_time_limit
	npc_spawned = false
	$HUD.update_score(score)
	$HUD.update_timer(game_timer)
	$HUD.show_message("Get Ready!")
	game_active = false
	
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("npcs", "queue_free")
	get_tree().call_group("items", "queue_free")
	
	await get_tree().process_frame
	
	var screen_size = get_viewport().get_visible_rect().size
	
	if has_node("Player"):
		var player = $Player
		player.show()
		if has_node("StartPosition"):
			player.start($StartPosition.position)
		else:
			player.start(screen_size * 0.5)
	
	spawn_mobs()
	spawn_npc()
	game_active = true

func spawn_mobs():
	# Use actual viewport size, not fixed size
	var screen_size = get_viewport().get_visible_rect().size
	print("Screen size: ", screen_size)
	
	var player_pos = Vector2.ZERO
	if has_node("Player") and $Player.visible:
		player_pos = $Player.position
	else:
		player_pos = screen_size * 0.5
	
	print("Player position: ", player_pos)
	print("Spawn margin: ", spawn_margin)
	
	# Ensure we have enough space for spawning
	if screen_size.x <= spawn_margin * 2 or screen_size.y <= spawn_margin * 2:
		print("ERROR: Screen too small for spawn margin!")
		return
	
	# Calculate spawn boundaries
	var min_x = spawn_margin
	var max_x = screen_size.x - spawn_margin
	var min_y = spawn_margin
	var max_y = screen_size.y - spawn_margin
	
	print("Spawn bounds: x(", min_x, " to ", max_x, ") y(", min_y, " to ", max_y, ")")
	
	var spawned_count = 0
	var max_attempts = 1000
	var attempt = 0
	
	# Simple approach: try random positions until we get enough valid ones
	while spawned_count < mob_count and attempt < max_attempts:
		var test_pos = Vector2(
			rng.randf_range(min_x, max_x),
			rng.randf_range(min_y, max_y)
		)
		
		# Check if far enough from player
		if test_pos.distance_to(player_pos) > 120:
			var mob = mob_scene.instantiate()
			mob.position = test_pos
			mob.rotation = 0
			add_child(mob)
			print("Spawned mob #", spawned_count + 1, " at: ", test_pos)
			spawned_count += 1
		
		attempt += 1
	
	if spawned_count < mob_count:
		print("Warning: Only spawned ", spawned_count, " out of ", mob_count, " mobs")
	else:
		print("Successfully spawned all ", mob_count, " mobs")

func spawn_npc():
	if npc_scene and not npc_spawned:
		var npc = npc_scene.instantiate()
		var screen_size = get_viewport().get_visible_rect().size
		
		# Use same margin system for NPC to ensure it's fully visible
		npc.position = Vector2(
			rng.randf_range(spawn_margin, screen_size.x - spawn_margin),
			rng.randf_range(spawn_margin, screen_size.y - spawn_margin)
		)
		
		if item_scene:
			npc.item_scene = item_scene
		add_child(npc)
		npc_spawned = true

func check_game_conditions():
	var remaining_mobs = get_tree().get_nodes_in_group("mobs").size()
	
	if remaining_mobs == 0:
		game_active = false
		victory()
		return
	
	if game_timer <= 0:
		game_active = false
		game_over_time_up()
		return

func victory():
	$Player.hide()
	$HUD.show_victory()
	score += 100
	$HUD.update_score(score)

func game_over_time_up():
	$Player.hide()
	$HUD.show_game_over_time()

func _on_golden_axe_picked_up():
	# Give 100 points bonus
	score += 100
	$HUD.update_score(score)

func _on_item_picked_up(item_type: String):
	match item_type:
		"health":
			score += 10
			print("Health item picked up!")
		"power":
			score += 20
			print("Power item picked up!")
		_:
			score += 5
	
	$HUD.update_score(score)

func _on_mob_destroyed():
	score += 10
	$HUD.update_score(score)
