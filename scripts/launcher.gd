extends Node2D

onready var baseCenter = Vector2.ZERO

export(PackedScene) var dotTraject = null
export(float) var gravityScale = 5.0
export(float) var forceScale = 2.0
export(int) var maxForceElastic = 200
export(int) var trajectorySegments = 30
export(int) var trajectorySpaceDots = 30
export(bool) var trajectoryDebug = false
export(bool) var trajectoryVisible = true

var velocityVector = Vector2.ZERO
var player_force = Vector2.ZERO
var mousepos = Vector2.ZERO

signal launch(position, offset, impulse)

func getTrajectoryPoint(start:Vector2, velocity:Vector2, n:float) -> Vector2:
	var t:float = 1 / 60.0;
	var tt:float = t * t;
	var stepVelocity:Vector2 = t * velocity
	var stepGravity:Vector2 = tt * Vector2(0, (-9.8 * gravityScale))
	
	var tpx:float = start.x + n * stepVelocity.x + 0.5 * (pow(n,2) + n) * stepGravity.x
	var tpy:float = start.y + n * stepVelocity.y + 0.5 * (pow(n,2) + n) * -stepGravity.y
	return Vector2(tpx, tpy)

func _physics_process(delta):
	for nd in get_tree().get_nodes_in_group("dots"):
		nd.queue_free()
		
	$elastic.clear_points()
	
	# retorna o icone ao ponto
	$image.rotation -= $image.rotation / 8
	
	player_force = baseCenter - get_local_mouse_position()
	

	if mousepos == Vector2.ZERO and !trajectoryDebug: return
	velocityVector = player_force.normalized() * (player_force.length() * forceScale)
	
	# elastic
	var percentColor = (player_force.length() * 100.0 / maxForceElastic) / 100.0
	$elastic.width = 10
	$elastic.default_color.r = (1 * percentColor)
	$elastic.default_color.g = 1-(1 * percentColor)
	$elastic.default_color.b = 0
	
	if player_force.length() < maxForceElastic:
		$elastic.add_point(baseCenter)
		$elastic.add_point(get_local_mouse_position())
		
		# rotaciona o lançador
		$image.rotate(player_force.angle() - $image.rotation)
		
		# desenha a trajetória
		if trajectoryVisible:
			drawTrajectory(trajectorySpaceDots, trajectorySegments)

func drawTrajectory(space:int = 20, segments:int = 100):
	if mousepos == Vector2.ZERO and !trajectoryDebug: return
	if !weakref(dotTraject).get_ref(): return
		
	var idx = 0
	for i in range(1,segments-1):
		var traj = getTrajectoryPoint(baseCenter, velocityVector, idx)
		var bb = dotTraject.instance()
		bb.add_to_group("dots")
		bb.global_position = Vector2(traj.x, traj.y)
		add_child(bb)
		idx += space

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		
		if !event.is_pressed():
			if mousepos != Vector2.ZERO:
				var distanceForce = velocityVector.length()
				var angle = velocityVector.angle()
				var velX = (PI * cos(angle) * (distanceForce))
				var velY = (PI * sin(angle) * (distanceForce))
				var imp = Vector2(velX, velY)
				emit_signal("launch", global_position, Vector2.ZERO, imp, distanceForce)
				if !trajectoryDebug: queue_free()
			mousepos = Vector2.ZERO

	if  event is InputEventScreenDrag:
		mousepos = event.position
		if player_force.length() > maxForceElastic:
			mousepos = Vector2.ZERO
			if !trajectoryDebug: queue_free()
