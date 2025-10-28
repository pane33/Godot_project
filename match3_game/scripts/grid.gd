extends Node2D

# grid var
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int

var all_pieces = []

var possible_pieces = [
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn"),
]

# main func: it start only 1 time
func _ready():
	randomize()
	all_pieces = make_2d_array()
	_spown_pices()

# it make 2dim array full of null
func make_2d_array():
	var array = []
	
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


# spown the pieces randomly on the grid node
func _spown_pices():
	for i in width:
		for j in height:
			# chose a random number and store it
			var rand = floor(randf_range(0, possible_pieces.size()))
			var scene: PackedScene = possible_pieces[rand]
			var piece = scene.instantiate()
			add_child(piece)
			piece.position = _grid_to_pixel(i, j)

# transform position any grid position in pixel position
func _grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)
