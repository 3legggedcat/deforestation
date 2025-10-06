extends CanvasLayer

signal start_game

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func show_game_over():
	
	hide_ui_elements()
	
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Cut the Trees!"
	$MessageLabel.show()
	await get_tree().create_timer(2.0).timeout
	
	
	show_ui_elements()
	$StartButton.show()

func show_game_over_time():
	
	hide_ui_elements()
	
	show_message("Time's Up!")
	await $MessageTimer.timeout
	$MessageLabel.text = "Try again"
	$MessageLabel.show()
	await get_tree().create_timer(3.0).timeout
	
	
	show_ui_elements()
	$StartButton.show()

func show_victory():
	
	hide_ui_elements()
	
	show_message("Victory!")
	await $MessageTimer.timeout
	$MessageLabel.text = "Well done!"
	$MessageLabel.show()
	await get_tree().create_timer(3.0).timeout
	
	
	show_ui_elements()
	$StartButton.show()

func hide_ui_elements():
	
	if has_node("ScoreLabel"):
		$ScoreLabel.hide()
	if has_node("TimerLabel"):
		$TimerLabel.hide()
	

func show_ui_elements():
	# Show score and timer again
	if has_node("ScoreLabel"):
		$ScoreLabel.show()
	if has_node("TimerLabel"):
		$TimerLabel.show()
	

func update_score(score):
	$ScoreLabel.text = "Score: " + str(score)

func update_timer(time_remaining: float):
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	$TimerLabel.text = "Time: %02d:%02d" % [minutes, seconds]
	
	if time_remaining < 30:
		$TimerLabel.modulate = Color.RED
	elif time_remaining < 60:
		$TimerLabel.modulate = Color.YELLOW
	else:
		$TimerLabel.modulate = Color.WHITE

func _on_start_button_pressed():
	$StartButton.hide()
	show_ui_elements()  
	start_game.emit()

func _on_message_timer_timeout():
	$MessageLabel.hide()
