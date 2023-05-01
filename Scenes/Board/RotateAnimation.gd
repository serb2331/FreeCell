extends Node

var anim_time = 0

func _ready():
	pass


func _on_Button_mouse_entered():
	$AnimationPlayer.play("Rotate")
	$AnimationPlayer.seek(anim_time)


func _on_Button_mouse_exited():
	anim_time = $AnimationPlayer.get_current_animation_position()
	$AnimationPlayer.stop()
