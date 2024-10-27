extends Node3D
		
		
@onready var player = get_tree().get_current_scene().get_node("Player")

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	$AudioManager.setupAudio(get_multiplayer_authority())
	$Nametag.text = str(get_multiplayer_authority())
	print(name + " " + str(get_multiplayer_authority()))
	

func _process(_delta):
	if multiplayer.multiplayer_peer != null and is_inside_tree():
		if is_multiplayer_authority():
			self.hide()

func _physics_process(_delta: float) -> void:
	if multiplayer.multiplayer_peer != null:
		if is_multiplayer_authority():
			update_self()
 

func update_self():
	$Left_hand.position = player.get_node("XRController3D_left").position
	$Right_hand.position = player.get_node("XRController3D_right").position
	$Head.rotation = player.get_node("XRCamera3D").rotation
	$Left_hand.rotation = player.get_node("XRController3D_left").rotation
	$Right_hand.rotation = player.get_node("XRController3D_right").rotation
	$Head.position = player.get_node("XRCamera3D").position
	$Nametag.position = player.get_node("XRCamera3D").position
	$Nametag.position.y += 0.4
	$Nametag.rotation = player.get_node("XRCamera3D").rotation
	$Nametag.rotation.y += 135
