extends Node2D

# Colore del pezzo (definito nella scena)
@export var color: String

# Tween per movimento animato e flag per match
var move_tween;
var match = false

func _ready():
	pass;

# Muove il pezzo verso una posizione target con animazione Tween
func move(target) -> Tween:
	# Crea un nuovo tween
	var tween = create_tween()

	# Anima la proprietà "position" verso il target in 0.5s con effetto elastico
	tween.tween_property(self, "position", target, 0.3) \
		 .set_trans(Tween.TRANS_ELASTIC) \
		 .set_ease(Tween.EASE_OUT)
	
	return tween

# Rende il pezzo semi-trasparente quando è parte di un match
func dim():
	var sprite = get_node("Sprite2D")
	sprite.modulate = Color(1, 1, 1, .5)
	pass
