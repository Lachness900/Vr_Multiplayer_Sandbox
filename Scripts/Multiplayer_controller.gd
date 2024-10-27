extends Node

@warning_ignore("unused_signal")
signal forced_disconnect

const IP_ADRESS = "127.0.0.1"
const PORT = 1027
const MAX_PLAYERS = 4
const OPEN_IP_ADRESS = "2403:5809:b9c7:0:ec97:13a8:ee2a:8e28"

#Default address 192.168.1.1

@export var multiplayer_player_scene : PackedScene = preload("res://Scenes/other_players.tscn")
@onready var player_spawn_node : Node3D = get_tree().get_current_scene().get_node("Players")
@onready var pickup_left_node = get_tree().get_current_scene().get_node("Player/XRController3D_left/XRToolsFunctionPickup")
@onready var pickup_right_node = get_tree().get_current_scene().get_node("Player/XRController3D_right/XRToolsFunctionPickup")

#
@onready var pickables = get_tree().get_nodes_in_group("Pickables")
var players = []
var held_items = [ ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(str(pickup_right_node))
	Gui.toggle_host_server.connect(host_server_button)
	Gui.toggle_join_server.connect(join_server_button)
	Gui.toggle_disconnect.connect(disconnect_button)
	
	
	#call_deferred("connect", pickup_left_node.has_picked_up, pickup_notification)
	#call_deferred("connect", pickup_right_node.has_picked_up, pickup_notification)
	#call_deferred("connect", pickup_left_node.has_dropped, dropped_notification)
	#call_deferred("connect", pickup_right_node.has_dropped, dropped_notification)
	pickup_left_node.has_picked_up.connect(pickup_notification)
	pickup_right_node.has_picked_up.connect(pickup_notification)
	#pickup_left_node.has_dropped.connect(dropped_notification)
	#pickup_right_node.has_dropped.connect(dropped_notification)
	for node in pickables:
		node.picked_up.connect(pickup_notification)
		#node.dropped.connect(dropped_notification)
	#player_node.get_node("XRController3D_left").get_node("XRToolsFunctionPickup").has_dropped.connect(dropped_notification)
	#player_node.get_node("XRController3D_right").get_node("XRToolsFunctionPickup").has_dropped.connect(dropped_notification)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func host_server_button():
	print("Starting host")
	var server_peer = ENetMultiplayerPeer.new()
	var error = server_peer.create_server(PORT,MAX_PLAYERS)
	if error != OK:
		print("cannot host: " + str(error))
		return
	server_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	if not multiplayer.is_connected("peer_connected", add_player):
		multiplayer.peer_connected.connect(add_player)
	if not multiplayer.is_connected("peer_disconnected", delete_player):
		multiplayer.peer_disconnected.connect(delete_player)
	multiplayer.multiplayer_peer = server_peer
	add_player(1)
	
	
func join_server_button():
	print("Joining server")
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(IP_ADRESS,PORT)
	client_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = client_peer


func disconnect_button():
	delete_player(multiplayer.get_unique_id())

#everyone
func add_player(id):
	#print("Added player " + str(id))
	var player = multiplayer_player_scene.instantiate()
	player.name = str(id)
	players.append_array([id])
	get_tree().call_group("pickables", "connect", "_on_picked_up", "pickup_notification")
	player_spawn_node.call_deferred("add_child", player)

#everyone
func delete_player(id):
	print("Deleted " + str(id) + " " + str(multiplayer.get_unique_id()))
	if id == 1:
		rpc("_close_server")
		multiplayer.multiplayer_peer = null
	elif multiplayer.get_unique_id() == id:
		rpc("_delete_player", id)
		for node in player_spawn_node.get_children():
			node.queue_free()
		Gui.on_forced_disconnect()
	
#everyone else
@rpc("any_peer","call_remote", "reliable")
func _delete_player(id):
	player_spawn_node.get_node(str(id)).queue_free()

#everyone
@rpc("any_peer", "call_local", "reliable")
func _close_server():
	print("Closed server " + str(multiplayer.get_unique_id()))
	for node in player_spawn_node.get_children():
		node.queue_free()
	Gui.on_forced_disconnect()

#client, give authority to piece on pickup and alert others
func pickup_notification(pickable):
	print("picked up " + str(pickable) + " " + str(multiplayer.get_unique_id()))
	pickable.set_multiplayer_authority(multiplayer.get_unique_id(), true)
	_check_pickup.rpc(pickable)

#others, give authority for client picking up and remove driver
@rpc("any_peer", "call_remote", "reliable", 1)
func _check_pickup(pickable):
	var pick = instance_from_id(pickable.object_id)
	pick.set_multiplayer_authority(multiplayer.get_remote_sender_id(), true)
	var pickup_node = pick.get_picked_up_by()
	if pickup_node != null and pickup_node.get_parent().name == 'Snap_Zones':
		pick._grab_driver.primary.by = null 
		#print("In snap_zone " + str(pick) + str(pickup_node.picked_up_object))
		#
		#pickup_node.set_multiplayer_authority(multiplayer.get_remote_sender_id(), true)
		#pickup_node.picked_up_object = null
	#print("picked up from " + str(pick.get_picked_up_by()) + " " + str(multiplayer.get_unique_id()))

##client
#func dropped_notification(pickable):
	#print("Dropped " + str(pickable))
	##pickable.set_multiplayer_authority(1, true)
	#_release_object.rpc(pickable, pickable.collision_layer)
#
##others
#@rpc("any_peer", "call_remote", "reliable", 2)
#func _release_object(pickable, coll_layer):
	#pickable.collision_layer = coll_layer
	#pass
