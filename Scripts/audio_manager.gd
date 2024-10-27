extends Node3D

var input : AudioStreamPlayer3D
var index : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
@export var outputPath : NodePath
@export var audio_distance = 3
var inputThreshold = 0.005
var receiveBuffer := PackedFloat32Array()
var receiving = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setupAudio(id):
	set_multiplayer_authority(id)
	if is_multiplayer_authority():
		input = $Input
		input.max_distance = audio_distance
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 0)
		receiving = true
	playback = get_node(outputPath).get_stream_playback()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if  multiplayer.multiplayer_peer != null and is_inside_tree():
		if receiving and is_multiplayer_authority():
			processMic()
		processVoice()
	pass

func processMic():
	var sterioData : PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	
	if sterioData.size() > 0:
		var data = PackedFloat32Array()
		data.resize(sterioData.size())
		var maxAmplitude := 0.0
		
		for i in range(sterioData.size()):
			var value = (sterioData[i].x + sterioData[i].y)/2
			maxAmplitude = max(value, maxAmplitude)
			data[i] = value
		if maxAmplitude < inputThreshold:
			return
		
		sendData.rpc(data)
		
func processVoice():
	if receiveBuffer.size() <= 0:
		return
	
	for i in range(min(playback.get_frames_available(), receiveBuffer.size())):
		playback.push_frame(Vector2(receiveBuffer[0], receiveBuffer[0]))
		receiveBuffer.remove_at(0)


@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendData(data):
	receiveBuffer.append_array(data)
