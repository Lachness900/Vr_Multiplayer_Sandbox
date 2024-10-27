extends MultiplayerSynchronizer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_piece_dropped(pickable: Variant) -> void:
	pass



func _on_piece_picked_up(pickable: Variant) -> void:
	#var pickup_node = pickable.get_picked_up_by()
	#if pickup_node != null and (pickup_node.get_parent().name == 'XRController3D_right' or pickup_node.get_parent().name == 'XRController3D_left'):
		#pickable.set_multiplayer_authority(multiplayer.get_unique_id())
	#if pickup_node != null and pickup_node.get_parent().name == 'Snap_Zones':
		#pickable.set_multiplayer_authority(1);
	pass
