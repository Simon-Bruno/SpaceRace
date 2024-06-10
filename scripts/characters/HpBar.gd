extends ProgressBar

var fill_stylebox: StyleBoxFlat
const health_bar_colors = preload("res://assets/characters/health_bar_colors.tres")

func _ready():
	# Create a unique instance of StyleBoxFlat for this ProgressBar
	var original_stylebox = get_theme_stylebox("fill", "ProgressBar")
	fill_stylebox = StyleBoxFlat.new()

	add_theme_stylebox_override("fill", fill_stylebox)

	_on_value_changed(value)  # Update the color based on the initial value

func _on_value_changed(new_value):
	print(new_value)
	fill_stylebox.bg_color = health_bar_colors.gradient.sample(1 - (new_value / max_value))
