extends Node2D

# Variabili esportate per definire la griglia
@export var width: int        # numero di colonne
@export var height: int       # numero di righe
@export var x_start: int      # posizione X iniziale della griglia
@export var y_start: int      # posizione Y iniziale della griglia
@export var offset: int       # distanza in pixel tra le celle

# Array delle possibili scene di pezzi caricabili
var possible_pieces = [
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn"),
]

# Contiene tutti i pezzi attualmente presenti sulla griglia
var all_pieces = []

# Variabili per il controllo del tocco (input)
var first_touch = Vector2(0,0)   # posizione iniziale del tocco
var final_touch = Vector2(0,0)   # posizione finale del tocco
var controlling = false          # indica se un tocco valido è in corso

# Funzione principale chiamata una sola volta all'avvio
func _ready():
	randomize()                   # randomizza il generatore di numeri casuali
	all_pieces = make_2d_array()  # inizializza la griglia
	_spown_pices()                # genera i pezzi iniziali

# Crea un array 2D riempito con valori null
func make_2d_array():
	var array = []
	
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

# Genera i pezzi sulla griglia in modo casuale
func _spown_pices():
	for i in width:
		for j in height:
			# Sceglie un indice casuale del pezzo da generare
			var rand = floor(randf_range(0, possible_pieces.size()))
			
			var scene: PackedScene = possible_pieces[rand]
			var piece = scene.instantiate()
			
			# Evita di creare subito combinazioni di 3 uguali
			var loops = 0
			while(_match_at(i, j, piece.color) && loops < 100):
				rand = floor(randf_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instantiate()
			
			# Istanzia il pezzo e lo posiziona sulla griglia
			add_child(piece)
			piece.position = _grid_to_pixel(i, j)
			all_pieces[i][j] = piece;

# Controlla se ci sono già 2 pezzi uguali adiacenti (evita spawn immediati di match)
func _match_at(i, j, color):
	if i > 1:
		if all_pieces[i -1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true

	if j > 1:
		if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color && all_pieces[i][j - 2].color == color:
				return true

# Converte coordinate di griglia in coordinate pixel
func _grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)

# Verifica che una posizione sia interna alla griglia
func _is_in_grid(column, row):
	if column >= 0 && column < width:
		if row >= 0 && row < height:
			return true
	return false

# Converte coordinate pixel in coordinate griglia
func _pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / -offset);
	return Vector2(new_x, new_y)

# Gestisce input touch/click per lo scambio dei pezzi
func _touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position()
		var grid_position = _pixel_to_grid(first_touch.x, first_touch.y)
		
		# Verifica che il tocco iniziale sia dentro la griglia
		if _is_in_grid(grid_position.x, grid_position.y):
			controlling = true  # input valido
		else:
			controlling = false
			return  # ignora input fuori griglia

	if Input.is_action_just_released("ui_touch") and controlling:
		final_touch = get_global_mouse_position()
		var final_grid_position = _pixel_to_grid(final_touch.x, final_touch.y)
		var first_grid_position = _pixel_to_grid(first_touch.x, first_touch.y)
		
		# Verifica che anche il rilascio sia valido
		if _is_in_grid(final_grid_position.x, final_grid_position.y):
			touch_difference(first_grid_position, final_grid_position)

		controlling = false # reset per il prossimo input

# Scambia due pezzi di posizione in base alla direzione passata
func swap_pieces(column: int, row: int, direction: Vector2):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	
	if first_piece != null && other_piece != null:
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		
		first_piece.move(_grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(_grid_to_pixel(column, row))
		find_matches()

# Calcola la direzione del movimento e richiama lo swap appropriato
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

# Funzione chiamata ogni frame
@warning_ignore("unused_parameter")
func _process(delta):
	_touch_input()
	pass;

# Controlla se ci sono tre pezzi uguali allineati in una direzione
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

# Trova tutte le combinazioni di pezzi uguali (3 in linea)
func find_matches():
	for i in width:
		for j in height:
			var piece = all_pieces[i][j]
			if piece == null:
				continue
			var color = piece.color
			_check_match_line(i, j, color, Vector2(1, 0))  # orizzontale
			_check_match_line(i, j, color, Vector2(0, 1))  # verticale
	get_parent().get_node("destroy_timer").start()

# Elimina i pezzi contrassegnati come "match"
func destroy_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].match:
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	get_parent().get_node("collapse_timer").start()

# Fa collassare i pezzi verso il basso per riempire gli spazi vuoti nella griglia
func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(_grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break

# Chiamata dal timer per eliminare i pezzi dopo un match
func _on_destroy_timer_timeout():
	destroy_matched()

# Chiamata del timer per attivare il collasso delle colonne dopo una distruzione
func _on_collapse_timer_timeout() -> void:
	collapse_columns()
