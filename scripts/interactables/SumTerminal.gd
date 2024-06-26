extends Node

func generate_new_screen():
	generate_new_sum()

var last_sum

func generate_new_sum():
	var num1 = randi_range(10, 200)
	var num2 = randi_range(10, 200)
	var operator = randi_range(0, 3)
	if operator == 0:
		var sum = num1 + num2
		var option1 = sum
		while option1 == sum:
			option1 = randi_range(sum - 20, sum + 20) 
		var option2 = sum
		while option2 == sum or option2 == option1:
			option2 = randi_range(sum - 20, sum + 20) 
		var options = [sum, option1, option2]
		options.shuffle()
		$Answer1.text = str(options[0])
		$Answer2.text = str(options[1])
		$Answer3.text = str(options[2])
		$Sum.text = str(num1) + " + " + str(num2)
		last_sum = sum
	if operator == 1:
		var sum = num1 * num2
		var option1 = sum
		while option1 == sum:
			option1 = randi_range(sum - 20, sum + 20) 
		var option2 = sum
		while option2 == sum or option2 == option1:
			option2 = randi_range(sum - 20, sum + 20) 
		var options = [sum, option1, option2]
		options.shuffle()
		$Answer1.text = str(options[0])
		$Answer2.text = str(options[1])
		$Answer3.text = str(options[2])
		$Sum.text = str(num1) + " * " + str(num2)
		last_sum = sum
	if operator == 2:
		var sum = num1 - num2
		var option1 = sum
		while option1 == sum:
			option1 = randi_range(sum - 20, sum + 20) 
		var option2 = sum
		while option2 == sum or option2 == option1:
			option2 = randi_range(sum - 20, sum + 20) 
		var options = [sum, option1, option2]
		options.shuffle()
		$Answer1.text = str(options[0])
		$Answer2.text = str(options[1])
		$Answer3.text = str(options[2])
		$Sum.text = str(num1) + " - " + str(num2)
		last_sum = sum

@rpc("any_peer", "call_local", "reliable")
func button_clicked(val):
	if not multiplayer.is_server():
		return 
	get_parent().get_parent().progress_updated(val == str(last_sum))	

func _on_answer_1_pressed():
	button_clicked.rpc($TextureRect/Answer1.text)

func _on_answer_2_pressed():
	button_clicked.rpc($TextureRect/Answer2.text)

func _on_answer_3_pressed():
	button_clicked.rpc($TextureRect/Answer3.text)
