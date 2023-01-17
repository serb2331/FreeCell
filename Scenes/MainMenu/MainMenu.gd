extends Control


func _ready():
	pass




func _on_StartButton_pressed():
	get_tree().change_scene("res://Scenes/Board/Board.tscn")
	pass


func _on_ExitButton_pressed():
	get_tree().quit()
	pass # Replace with function body.

