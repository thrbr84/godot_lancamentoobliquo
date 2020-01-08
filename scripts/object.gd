extends RigidBody2D

onready var line:Object = Line2D.new()

export(bool) var autoRotate = true
export(Gradient) var trailColor = null
export(int) var trailWidth = 60
export(int) var distanceForce = 0

var collided:bool = false

signal collide(distanceForce)

func _ready():
	#EN: Put the trail line configurations
	#PT: Coloca as configurações do rastro
	line.gradient = trailColor
	line.width = trailWidth
	get_parent().add_child(line)

func _physics_process(delta):
	#EN: Draw de trail line if tail size is less than (int number)
	#PT: Desenha o rastro se o tamanho da linha for (número inteiro)
	if line.points.size() < 50:
		line.add_point(global_position)
		line.z_index = 0
	
	#EN: If de trail larger than (int number) then remove index 0
	#PT: Se o rastro for tiver mais que (numero inteiro) de pontos, então começa removendo o indice 0
	while line.get_point_count() > 20:
		line.remove_point(0)
		
func _integrate_forces(state):
	#EN: Just enter this part if (autoRotate==true), this makes RigidBody2D auto rotate according to the angle of the parable
	#PT: Só entra nessa parte se (autoRotate==true), isso faz o RigidBody2D auto rotacionar de acordo com o ângulo da parábola.
	if !autoRotate: return
	var lv = state.get_linear_velocity()
	var av = state.get_angular_velocity()
	var delta = 1 / state.get_step()
	
	#EN: If not collided with nobody, then adjust the angle
	#PT: Enquanto não colidir, então pode ajustar o próprio ângulo
	if !collided and state.get_contact_count() == 0:
		linear_damp = 0
		angular_damp = 0

		av = (lv.angle() - rotation) * delta
		state.set_angular_velocity(av)
	else:
		#EN: After the first collision, then adjust linear and velocity damp to brake the body
		#PT: Após sua primeira colisão, então para de corrigir o ângulo, e configura o velocity e angular damp para começar a frear o corpo
		linear_damp = .2
		angular_damp = .2

func _on_checkCollision_body_entered(body):
	#EN: This code is required to notify this body that there was a collision, "state.get_contact_count()" was supposed to work for this, but I don't know why it didn't work so I made this fix
	#PT: Esse código notifica o corpo que houve uma colisão, a função "state.get_contact_count()" deveria ser suficiente para isso, porém nos meus testes não funcionou, então fiz esse código
	if body != self and !collided:
		collided = true
		
		#EN: Just a signal for "parent connected" to trigger some effects when colliding
		#PT: Só um sinal para o "pai conectado" realizar alguns efeitos quando colidir
		#if body.is_in_group("floor"): 
		emit_signal("collide", distanceForce)


func _on_object_sleeping_state_changed():
	#EN: If all velocity stop, then free
	#PT: Se parar o movimento por completo então remove
	if sleeping:
		_on_visibility_screen_exited()

func _on_visibility_screen_exited():
	if weakref(line).get_ref(): line.queue_free()
	queue_free()
