extends MultiplayerSynchronizer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# When a client's snap zone pick a pickable up, give it authority and initalization
func _on_snap_zone_has_picked_up(what: Variant) -> void:
	var snap_zone = self.get_parent()
	snap_zone.picked_up_object = what
	what._grab_driver.primary.by = snap_zone
	snap_zone.set_multiplayer_authority(what.get_multiplayer_authority(), true)
	_on_foriegn_snap_zone_pickup.rpc(what, snap_zone)
	pass # Replace with function body.

# When a client picks up something from a snap zone, delete data in it and give authority
func _on_snap_zone_has_dropped(what: Variant) -> void:
	var snap_zone = self.get_parent()
	snap_zone.picked_up_object = null
	#what.set_multiplayer_authority(multiplayer.get_unique_id(), true)
	snap_zone.set_multiplayer_authority(multiplayer.get_unique_id(), true)
	pass # Replace with function body.

# When another client's snap zone pick a pickable up, give it authority and initalization
@rpc("any_peer", "call_remote", "reliable")
func _on_foriegn_snap_zone_pickup(what: Variant, zone):
	var pick = instance_from_id(what.object_id)
	var snap_zone = instance_from_id(zone.object_id)
	snap_zone.picked_up_object = pick
	pick._grab_driver.primary.by = snap_zone
	self.get_parent().set_multiplayer_authority(multiplayer.get_remote_sender_id(), true)
