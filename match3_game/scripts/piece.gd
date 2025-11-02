extends Node2D

@export var color: String

var move_tween;
var match = false


func _ready():
	
	pass;

func move(target):
	# 1. Crei un nuovo tween. Sostituisce la variabile onready.
	var tween = create_tween()

	# 2. Usi tween_property per animare.
	tween.tween_property(self, "position", target, 0.5) \
		 .set_trans(Tween.TRANS_ELASTIC) \
		 .set_ease(Tween.EASE_OUT)

	# 3. Non serve .start()! Il tween parte da solo.
	pass;

func dim():
	var sprite = get_node("Sprite2D")
	sprite.modulate = Color(1, 1, 1, .5)
	pass
