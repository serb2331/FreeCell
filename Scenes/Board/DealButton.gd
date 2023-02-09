extends Sprite

var anim_time = 0

func _ready():
	pass

func _on_DealCardsButton_mouse_entered():
	$AnimationPlayer.play("Big")
	$AnimationPlayer.seek(anim_time)
	pass


func _on_DealCardsButton_mouse_exited():
	anim_time = $AnimationPlayer.get_current_animation_position()
	$AnimationPlayer.stop()
	pass
