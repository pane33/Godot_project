extends Sprite2D

var speed : float = 100.0

func _process(delta):
	var position = Vector2(1,0)
	
	global_position += position * speed * delta
	rotation_degrees += 10 * speed * delta
