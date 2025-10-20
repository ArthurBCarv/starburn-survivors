extends Node

var current_wave: int = 1
var game_time: float = 0.0
var is_paused: bool = false
var player: Node = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if not is_paused:
		game_time += delta

func pause_game():
	is_paused = true
	get_tree().paused = true

func resume_game():
	is_paused = false
	get_tree().paused = false

func get_player() -> Node:
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	return player
