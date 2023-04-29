extends Sprite

var anim_time = 0

func _ready():
	pass

func _on_Button_mouse_entered():
	if (!$AnimationPlayer.is_playing()):
		$AnimationPlayer.play("Flip")

