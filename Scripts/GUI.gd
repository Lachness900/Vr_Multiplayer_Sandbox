extends CanvasLayer

@warning_ignore("unused_signal")
signal toggle_reset_board
@warning_ignore("unused_signal")
signal toggle_host_server
@warning_ignore("unused_signal")
signal toggle_join_server
@warning_ignore("unused_signal")
signal toggle_disconnect
@warning_ignore("unused_signal")
signal toggle_sync_chess


# Called when the node enters the scene tree for the first time.
@onready var button_node = $"/root/Node3D/GUI/Viewport"

func _ready():
	MultiplayerController.forced_disconnect.connect(on_forced_disconnect)
	await get_tree().create_timer(1.0).timeout
	button_node = button_node.get_child(-1).get_child(-1).get_child(-1)
	#button_node = call_deferred("get_child", button_node, -1)
	#button_node = call_deferred("get_child", button_node, -1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_reset_board_pressed():
	Gui.toggle_reset_board.emit()

#client function
func _on_host_server_pressed():
	$"MarginContainer/VBoxContainer/Host_Server".disabled = true
	$"MarginContainer/VBoxContainer/Join_Server".disabled = true
	$"MarginContainer/VBoxContainer/Host_Server".visible = false
	$"MarginContainer/VBoxContainer/Join_Server".visible = false
	$"MarginContainer/VBoxContainer/Disconnect".disabled = false
	$"MarginContainer/VBoxContainer/Disconnect".visible = true
	$"MarginContainer/VBoxContainer/Sync_Chess".disabled = false
	$"MarginContainer/VBoxContainer/Sync_Chess".visible = true
	Gui.toggle_host_server.emit()
	
#client function
func _on_join_server_pressed():
	$"MarginContainer/VBoxContainer/Host_Server".disabled = true
	$"MarginContainer/VBoxContainer/Join_Server".disabled = true
	$"MarginContainer/VBoxContainer/Host_Server".visible = false
	$"MarginContainer/VBoxContainer/Join_Server".visible = false
	$"MarginContainer/VBoxContainer/Disconnect".disabled = false
	$"MarginContainer/VBoxContainer/Disconnect".visible = true
	$"MarginContainer/VBoxContainer/Sync_Chess".disabled = false
	$"MarginContainer/VBoxContainer/Sync_Chess".visible = true
	Gui.toggle_join_server.emit()

#client function
func _on_disconnect_pressed() -> void:
	Gui.toggle_disconnect.emit()

#server function
func on_forced_disconnect():
	button_node.get_node("Disconnect").disabled = true
	button_node.get_node("Disconnect").visible = false
	button_node.get_node("Sync_Chess").disabled = true
	button_node.get_node("Sync_Chess").visible = false
	button_node.get_node("Host_Server").disabled = false
	button_node.get_node("Host_Server").visible = true
	button_node.get_node("Join_Server").disabled = false
	button_node.get_node("Join_Server").visible = true
	
	
#client function
func _on_sync_chess_pressed() -> void:
	Gui.toggle_sync_chess.emit()
