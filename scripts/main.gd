extends Node2D

export(PackedScene) var object = null
export(PackedScene) var launcher = null



func _on_launch(position=Vector2.ZERO, offset=Vector2.ZERO, impulse=Vector2.ZERO, distanceForce:int=0):
	#EN: This function is called when ScreenDrag is released
	#PT: Essa função é chamada quando o ScreenDrag foi solto
	
	#EN: If object reference not exists, then return!
	#PT: Se a referência do objeto não existe, então para aqui.
	if !weakref(object).get_ref(): return
	
	#EN: Instance of the object to be launch and settings
	#PT: Instancia do objeto que será lançado, e configura
	var o = object.instance()
	o.distanceForce = distanceForce
	o.global_position = position
	o.connect("collide", self, "_on_object_collide")
	add_child(o)
	#EN: Apply the impulse and offset received in parameters function
	#PT: Aplica o impulso e o offset recebido nos parametros da função
	o.apply_impulse(offset, impulse)

func _unhandled_input(event):
	if !weakref(launcher).get_ref(): return
	if event is InputEventMouseButton:
		#EN: If the mouse button or touch screen
		#PT: Se o mouse ou a tela for pressionada
		if event.is_pressed():
			#EN: Clean all the old launchers instanced by group name
			#PT: Limpa todos os objetos no grupo "launcher"
			for nd in get_tree().get_nodes_in_group("launcher"):
				nd.queue_free()
			
			#EN: Launcher object instance, it has all physics calculations
			#PT: Instância do objeto lançador, ele possui os cálculos de física
			var l = launcher.instance()
			l.global_position = event.position
			l.connect("launch", self, "_on_launch")
			add_child(l)

func _on_object_collide(distanceForce=0):
	#EN: Shake the screen when the object launched is collided
	#PT: Agita a tela quando o objecto lançado colidir
	$camera.shake(
		distanceForce * .002,
		distanceForce * .08,
		distanceForce * .05 
	)
