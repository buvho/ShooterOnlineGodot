extends Line2D
var tempoInicial = 0.2
var posicao_inicial = Vector2.ZERO
var posicao_final = Vector2.ZERO
var direcao : Vector2
var distancia : float
@onready var tempo = tempoInicial
func _ready():
	add_point(posicao_inicial)
	distancia = posicao_inicial.distance_to(posicao_final)
	direcao = posicao_inicial.direction_to(posicao_final)
	add_point(posicao_final)
func _process(delta):
	tempo -= delta
	if tempo <= 0:
		free()
	else:
		default_color.a = 1 * tempo / tempoInicial
		#points[1] = posicao_inicial + (direcao * distancia * abs(tempo / tempoInicial - 1))
