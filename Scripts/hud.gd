extends CanvasLayer

@export var player_path: NodePath
var player: Node = null
@onready var vida_label = $HealthLabel
@onready var wave_label = $WaveLabel
@onready var health_bar = $HealthBar

func _ready():
	player = get_node(player_path)
	if not player:
		push_error("Player não encontrado no HUD!")

func _process(delta):
	if player:
		health_bar.value = player.health
		health_bar.max_value = player.max_health
		
	

func set_wave(wave):
	wave_label.text = "Wave: %d" % wave
