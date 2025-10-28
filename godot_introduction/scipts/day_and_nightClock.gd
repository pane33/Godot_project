extends DirectionalLight3D

var sun = 0
var speed : float = 1.0

func _process(delta):
	rotation = Vector3(sun, 0,0)
	sun += delta * speed
	
	
