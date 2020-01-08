extends Node2D

export(PackedScene) var object = null
export(PackedScene) var launcher = null
	
func _on_launch(position=Vector2.ZERO, offset=Vector2.ZERO, impulse=Vector2.ZERO, distanceForce:int=0):
	if !weakref(object).get_ref(): return
	var o = object.instance()
	o.distanceForce = distanceForce
	o.global_position = position
	o.connect("collide", self, "_on_object_collide")
	add_child(o)
	o.apply_impulse(offset, impulse)

func _unhandled_input(event):
	if !weakref(launcher).get_ref(): return
	if event is InputEventMouseButton:
		if event.is_pressed():
			for nd in get_tree().get_nodes_in_group("person"):
				nd.queue_free()
				
			var l = launcher.instance()
			l.global_position = event.position
			l.connect("launch", self, "_on_launch")
			add_child(l)

func _on_object_collide(distanceForce=0):
	$camera.shake(distanceForce*.002, distanceForce*.08, distanceForce/20)
