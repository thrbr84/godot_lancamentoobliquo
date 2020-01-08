extends Node2D

var posini = Vector2(146, 600)
var velocidade = Vector2(200, -200)

func _ready():


	# VECTOR2D
	var _vector1 = Vector2(4, -4)
	
	# LENGTH_SQUARED
	var _length_squared = sqrt(pow(_vector1.x, 2) + pow(_vector1.y, 2))
	prints('LENGTH SQUARED:', _length_squared, _vector1.length())
	
	# LENGTH
	var _length = pow(_vector1.x, 2) + pow(_vector1.y, 2)
	prints('LENGTH:', _length, _vector1.length_squared())
	
	# NORMALIZED
	var _normalized = Vector2(_vector1.x / _length_squared, _vector1.y / _length_squared)
	prints('NORMALIZED:', _normalized, _vector1.normalized())
	
	# COSENO
	var _cos = _vector1.x / _length_squared
	prints('COS:', _cos, cos(_vector1.angle()))
	
	# SENO
	var _sin = _vector1.y / _length_squared
	prints('SIN:', _sin, sin(_vector1.angle()))
	
	# ANGLE
	prints('ANGLE:', _vector1.angle(), rad2deg(_vector1.angle()))
	
	
	#$icon.show()
	$icon.global_position = posini
	
	
	
func _physics_process(d):
	var delta = 1 / 60.0
	
	velocidade.x += 0 * delta
	velocidade.y += 98 * delta
	#velocidade.y += 98 * delta # COM GRAVIDADE
	
	$icon.global_position += velocidade * delta
	
	# Rotacionar
	$icon.rotate((velocidade.angle() - $icon.rotation) * delta)
	
	
	
