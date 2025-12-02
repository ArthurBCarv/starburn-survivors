extends Control

@onready var btn_iniciar = $MarginContainer/HBoxContainer/VBoxContainer/Iniciar
@onready var btn_sair = $MarginContainer/HBoxContainer/VBoxContainer/Sair

func _ready():
	btn_iniciar.pressed.connect(_on_iniciar_pressed)
	btn_sair.pressed.connect(_on_sair_pressed)
	
	btn_iniciar.grab_focus()

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://levels/arena/Game.tscn")

func _on_sair_pressed():
	get_tree().quit()
