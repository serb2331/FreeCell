extends Sprite

var anim_time = 0

func _ready():
	pass


func _on_RestartButton_mouse_entered():
	$AnimationPlayer.play("Rotate")
	$AnimationPlayer.seek(anim_time)
	pass # Replace with function body.


func _on_RestartButton_mouse_exited():
	anim_time = $AnimationPlayer.get_current_animation_position()
	$AnimationPlayer.stop()
	pass # Replace with function body.
