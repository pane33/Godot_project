extends Node2D

# grid var
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int

# 

# pieces array
var possible_pieces = [
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn"),
]

# current piece in the scene
var all_pieces = []

#touch var
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

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
			
			var loops = 0
			while(_match_at(i, j, piece.color) && loops < 100):
				rand = floor(randf_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instantiate()
			# instance that piece from the array
			add_child(piece)
			piece.position = _grid_to_pixel(i, j)
			all_pieces[i][j] = piece;

func _match_at(i, j, color):
	if i > 1:
		if all_pieces[i -1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true

	if j > 1:
		if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color && all_pieces[i][j - 2].color == color:
				return true

# transform position: any grid position in pixel position
func _grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)

# verify if is the space of the grid
func _is_in_grid(column, row):
	if column >= 0 && column < width:
		if row >= 0 && row < height:
			return true
	return false

# transform position: any pixel position in grid position
func _pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / -offset);
	return Vector2(new_x, new_y)

# 
func _touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position()
		var grid_position = _pixel_to_grid(first_touch.x, first_touch.y)
		
		# verifica che il click iniziale sia valido
		if _is_in_grid(grid_position.x, grid_position.y):
			controlling = true # first_position is good we can go to the final_position
		else:
			controlling = false
			return  # ignora l'input fuori griglia

	if Input.is_action_just_released("ui_touch") and controlling:
		final_touch = get_global_mouse_position()
		var final_grid_position = _pixel_to_grid(final_touch.x, final_touch.y)
		var first_grid_position = _pixel_to_grid(first_touch.x, first_touch.y) # has to be redeclared

		# verifica che anche il rilascio sia valido
		if _is_in_grid(final_grid_position.x, final_grid_position.y):
			touch_difference(first_grid_position, final_grid_position)

		controlling = false # reinizialized for other touch

func swap_pieces(column: int, row: int, direction: Vector2):
	
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	
	all_pieces[column][row] = other_piece
	all_pieces[column + direction.x][row + direction.y] = first_piece
	
	first_piece.move(_grid_to_pixel(column + direction.x, row + direction.y))
	other_piece.move(_grid_to_pixel(column, row))
	find_matches()

func touch_difference(pos_grid_1, pos_grid_2):
	var difference = pos_grid_2 - pos_grid_1
	
	# Swap orizzontale
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			# Muovi a destra
			swap_pieces(pos_grid_1.x, pos_grid_1.y, Vector2(1,0))
		elif difference.x < 0:
			# Muovi a sinistra
			swap_pieces(pos_grid_1.x, pos_grid_1.y, Vector2(-1,0))
	
	# Swap verticale
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			# Muovi in alto 
			swap_pieces(pos_grid_1.x, pos_grid_1.y, Vector2(0,1))
		elif difference.y < 0:
			# Muovi in basso 
			swap_pieces(pos_grid_1.x, pos_grid_1.y, Vector2(0,-1))

@warning_ignore("unused_parameter")
func _process(delta):
	_touch_input()
	pass;

func _check_match_line(i, j, color, dir: Vector2):
	var i1 = i - int(dir.x)
	var j1 = j - int(dir.y)
	var i2 = i + int(dir.x)
	var j2 = j + int(dir.y)
	
	if not _is_in_grid(i1, j1) or not _is_in_grid(i2, j2):
		return
	var a = all_pieces[i1][j1]
	var b = all_pieces[i2][j2]
	if a == null or b == null:
		return
	if a.color == color and b.color == color:
		for p in [a, all_pieces[i][j], b]:
			p.match = true
			p.dim()

func find_matches():
	for i in width:
		for j in height:
			var piece = all_pieces[i][j]
			if piece == null:
				continue
			var color = piece.color
			_check_match_line(i, j, color, Vector2(1, 0))  # orizzontale
			_check_match_line(i, j, color, Vector2(0, 1))  # verticale
