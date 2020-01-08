extends Node2D

onready var baseCenter = Vector2.ZERO

export(PackedScene) var dotTraject = null
export(float) var gravityScale = 5.0
export(float) var forceScale = 2.0
export(int) var maxForceElastic = 200
export(int) var elasticSize = 20
export(int) var trajectorySegments = 30
export(int) var trajectorySpaceDots = 30
export(bool) var trajectoryDebug = false
export(bool) var trajectoryVisible = true

var mousepos:Vector2 = Vector2.ZERO
var velocityVector:Vector2 = Vector2.ZERO
var player_distance:Vector2 = Vector2.ZERO
var player_force:int = 0

signal launch(_position, _offset, _impulse)

func getTrajectoryPoint(_start:Vector2, _velocity:Vector2, _n:float) -> Vector2:
	#EN: Get the Default Gravity in Project Settings
	#PT: Obtém o valor default da gravidade configurada no projeto 
	var gravity:float = ProjectSettings.get("physics/2d/default_gravity") / 10.0
	
	## Formula de Torricelli = V2 = V02 + 2*a2*Ds
	#EN: Take the rise time
	#PT: Aqui pegamos o tempo de subida
	var t:float = 1 / 60.0;
	#EN: Take the total rise time
	#PT: Tempo total de subida
	var tt:float = pow(t, 2);
	#EN: Calculate each step horizontally and vertically
	#PT: Calcular cada passo na horizontal e vertical
	var stepVelocity:Vector2 = t * _velocity
	var stepGravity:Vector2 = tt * Vector2(0, (-gravity * gravityScale))
	#EN: Apply the formula
	#PT: Aplicar a fórmula
	var tpx:float = _start.x + _n * stepVelocity.x + 0.5 * (pow(_n, 2) + _n) * stepGravity.x
	var tpy:float = _start.y + _n * stepVelocity.y + 0.5 * (pow(_n, 2) + _n) * -stepGravity.y
	return Vector2(tpx, tpy)

func _physics_process(delta):
	#EN: Clear old instance of node in group
	#PT: Limpa os objetos instanciados no grupo
	for nd in get_tree().get_nodes_in_group("dots"):
		nd.queue_free()
	
	#EN: Clear Line2D points
	#PT: Limpa todos os pontos do Line2D
	$elastic.clear_points()
	
	#EN: When mouse move, the sprite is rotated, this line, back the sprite to rotation=0 if the mouse out of limits
	#PT: Quando o mouse se movimenta, o sprite é rotacionado, a linha abaixo retorna a rotação para 0 se o mouse sair dos limites
	$image.rotation -= $image.rotation / 8
	
	#EN: Calculate the distance between base position and the local mouse position
	#PT: Calcula a distancia entre a posição da base e a posição do mouse
	player_distance = baseCenter - get_local_mouse_position()
	#EN: Find the force applied
	#PT: Encontra a força aplicada
	player_force = player_distance.length()

	#EN: If the mouse has not started dragging
	#PT: Se o mouse ainda não começou a puxar (DRAG)
	if mousepos == Vector2.ZERO and !trajectoryDebug: return
	
	#EN: Normalize the distance to apply the force and forceScale
	#PT: Normalizando a distância para aplicar a força e forceScale
	velocityVector = player_distance.normalized() * (player_force * forceScale)
	
	#EN: Colorify the elastic to green if less force and red to max force
	#PT: Colorir o elástico para verde se menos força e vermelho para força máxima
	var percentColor = (player_force * 100.0 / maxForceElastic) / 100.0
	$elastic.width = elasticSize
	$elastic.default_color.r = (1 * percentColor) #RED
	$elastic.default_color.g = 1-(1 * percentColor) #GREEN
	$elastic.default_color.b = 0 #BLUE
	
	#EN: If the elastic force less than limit to force
	#PT: Se a força aplicada no elástico está dentro do limite
	if player_force < maxForceElastic:
		#EN: Draw the elastic point in Line2D
		#PT: Desenha o ponto do elástico no Line2D
		$elastic.add_point(baseCenter)
		$elastic.add_point(get_local_mouse_position())
		
		#EN: Rotates the image to follow the angle of the parable
		#PT: Rotaciona a imagem para acompanhar o ângulo da parábola
		$image.rotate(player_distance.angle() - $image.rotation)
		
		#EN: Draw the trajectory line
		#PT: Desenha a linha da trajetória
		if trajectoryVisible:
			drawTrajectory(trajectorySpaceDots, trajectorySegments)

func drawTrajectory(space:int = 20, segments:int = 100):
	if mousepos == Vector2.ZERO and !trajectoryDebug: return
	if !weakref(dotTraject).get_ref(): return
		
	var idx = 0
	#EN: Loops the number of segments defined for the parable.
	#PT: Faz um looping na quantidade de segmentos definidos para a parábola
	for i in range(1,segments-1):
		var traj = getTrajectoryPoint(baseCenter, velocityVector, idx)
		#EN: Instantiates a scene to the parable points
		#PT: Instancia uma scena para os pontos da parábola
		var bb = dotTraject.instance()
		bb.add_to_group("dots") # Importante to queue_free()
		bb.global_position = Vector2(traj.x, traj.y)
		add_child(bb)
		#EN: Space between segments
		#PT: Espaço entre os segmentos
		idx += space

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		
		#EN: If the mouse is released
		#PT: Se o mouse foi solto
		if !event.is_pressed():
			#EN: If the mouse position not defined
			#PT: Se a posição do mouse não estiver definida
			if mousepos != Vector2.ZERO:
				#EN: Start of impulse calculations //-->
				#PT: Início dos cálculos para o impulso //-->
				
				#EN: Get the force applied on the elastic
				#PT: Pega a força aplicada no elástico
				var distanceForce = velocityVector.length()
				#EN: Get the angle of the force
				#PT: Pega o ângulo da força
				var angle = velocityVector.angle()
				
				#Formule: I=F.Dt
				
				#EN: Here we apply a formula to calculate the impulse to get how much force has been applied over time
				#PT: Aqui aplicamos uma fórmula para calcular o impulso, para obter o quanto de força foi aplicada pelo tempo
				var velX = (PI * cos(angle) * (distanceForce))
				var velY = (PI * sin(angle) * (distanceForce))
				#EN: Send the signal with the impulso value
				#PT: Envie o sinal com o valor do impulso
				var imp = Vector2(velX, velY)
				emit_signal("launch", global_position, Vector2.ZERO, imp, distanceForce)
				if !trajectoryDebug: queue_free()
			mousepos = Vector2.ZERO

	if  event is InputEventScreenDrag:
		mousepos = event.position
		#EN: Se the mouse out of the elastic limits, then self remove
		#PT: Se o mouse estiver fora dos limites elásticos, remova-o automaticamente
		if player_force > maxForceElastic:
			mousepos = Vector2.ZERO
			if !trajectoryDebug: queue_free()
