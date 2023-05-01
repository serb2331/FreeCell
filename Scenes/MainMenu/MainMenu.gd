extends Control

func _ready():
	$SFXToggleButton.pressed = !Utils.sfx_toggle

func _on_StartButton_pressed():
	get_tree().change_scene("res://Scenes/Board/Board.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_RulesButton_pressed():
	$RulesPanel.show()

func _on_RulesCloseButton_pressed():
	$RulesPanel.hide()

func _on_SFXToggleButton_toggled(button_pressed):
	Utils.sfx_toggle = !button_pressed



