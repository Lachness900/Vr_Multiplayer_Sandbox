extends Node3D

var chess_snaps
var chess_pieces
var chess_init_positions = []



# Called when the node enters the scene tree for the first time.
func _ready():
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		get_viewport().use_xr = true
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	Gui.toggle_reset_board.connect(reset_board_button)
	Gui.toggle_sync_chess.connect(sync_button)
	
	chess_snaps = $"Chess Board/Snap_Zones".get_children()
	chess_pieces = $"Chess Pieces".get_children()
	for chess_piece in chess_pieces:
		chess_init_positions.append(chess_piece.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func reset_board_button():
	for chess_piece in chess_pieces:
		chess_piece.drop() 
		chess_piece.original_chess_node.drop_object()
		chess_piece.original_chess_node.pick_up_object(chess_piece)

func sync_button():
	for chess_snap in chess_snaps:
		chess_snap.enabled = false
	await get_tree().create_timer(0.1).timeout
	for chess_snap in chess_snaps:
		chess_snap.enabled = true
