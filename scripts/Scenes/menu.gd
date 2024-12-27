extends Control
class_name Menu

static var skin_ID = 0
const skin_quant = 6
static var nome
static var skin_list = {
0: ["res://textures/player/cara.png","res://textures/player/Mão.png"],
1: ["res://textures/player/cara2.png","res://textures/player/Mão2.png"],
2: ["res://textures/player/cara3.png","res://textures/player/Mão3.png"],
3: ["res://textures/player/cara4.png","res://textures/player/Mão.png"],
4: ["res://textures/player/cara5.png","res://textures/player/Mão4.png"],
5: ["res://textures/player/cara6.png","res://textures/player/Mão3.png"],
6: ["res://textures/player/Blugget.png","res://textures/player/MãoNugget.png"]}
static var n1 = ["Homem","Cr7","Neymar","Polonia","Socorro","Gyat","Jotao","Nerd","Messi","noobdog"]
static var n2 = ["Rapido","DoSucesso","Horroroso","MeioGay","Goat","Gyat","Nhonho","Malvadeza","Gigantenorme","Ganhador","Perdedor"]
@onready var display = $Panel/PlayerEdit/PanelContainer/TextureRect
func on_ready():
	multiplayer.connected_to_server.connect(_on_connected)
func _on_left_pressed():
	if skin_ID == 0:
		skin_ID = skin_quant
	else:
		skin_ID -= 1
	display.texture = load(skin_list[skin_ID][0])

func _on_right_pressed():
	if skin_ID == skin_quant:
		skin_ID = 0
	else:
		skin_ID += 1
	display.texture = load(skin_list[skin_ID][0])

func _on_connected():
	nome = $Panel/PlayerEdit/NameEdit.text
	visible = false
	
static func get_player_name():
	if !nome:
		nome = (n1[randi() % n1.size()] + n2[randi() % n2.size()])
	return nome
