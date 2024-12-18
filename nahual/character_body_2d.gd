extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_tree: AnimationTree = $Sprite2D/AnimationTree
@onready var anim_player: AnimationPlayer = $Sprite2D/AnimationPlayer

@onready var raycast: RayCast2D = $RayCast2D
var distancia_raycast

const SPEED = 60.0
const SPEED_TRANSFORMADA = 100.0
const DISTANCIA_TRANSFORMACION = 150.0
const DISTANCIA_ALCANZAR = 40.0

const ataque = 1.1
var dano = 0
var cooldown = .9
var t = .9
var direccion_Ataque = 1

var personaje = null
var direccion = 0
var atacable : bool = false
var transformada : bool = false
var objeto_Atacado = null

var atacado : bool = false : set = set_Atacado
var vida = 3

func _physics_process(delta: float) -> void:
	# Añadir gravedad.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		var position_objetivo = Vector2(personaje.position.x, self.position.y)
		var distancia = position.distance_to(position_objetivo)

		# Verificar la distancia para transformar o regresar al estado inicial
		verificar_transformacion(distancia)
		
		if distancia > DISTANCIA_ALCANZAR:
			# Calcular dirección y movimiento
			direccion = position.direction_to(position_objetivo).x
			velocity = position.direction_to(position_objetivo) * (SPEED_TRANSFORMADA if transformada else SPEED)
			if direccion > 0:
				sprite.scale.x = 1
				raycast.target_position.x = distancia_raycast
			else:
				sprite.scale.x = -1
				raycast.target_position.x = -distancia_raycast
			
			# Activar animación de caminar
			anim_tree["parameters/walk/blend_amount"] = 1
		else:
			# Si está cerca, detener movimiento y activar animación de ataque
			velocity = Vector2.ZERO
			anim_tree["parameters/walk/blend_amount"] = 0
			anim_tree["parameters/Ataque/blend_amount"] = 1
			if raycast.is_colliding():
				objeto_Atacado = raycast.get_collider()
				if objeto_Atacado == personaje:
					personaje.dano_Recibido(dano, direccion)
	
	move_and_slide()

func _ready() -> void:
	personaje = get_parent().get_node("main_char")
	distancia_raycast = raycast.target_position.x

func verificar_transformacion(distancia: float) -> void:
	if distancia >= DISTANCIA_TRANSFORMACION and not transformada:
		transformarse()
	elif distancia <= DISTANCIA_ALCANZAR and transformada:
		regresar_estado_inicial()

func transformarse() -> void:
	transformada = true
	anim_tree["parameters/transformación/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	dash_Animation (direccion, 120, .5)


func regresar_estado_inicial() -> void:
	transformada = false
	anim_tree["parameters/Ataque/blend_amount"] = 1
	

func dash_Animation(direccion_Dash, incremento, tiempo):
	var pos_Ini = position
	var pos_Fin = pos_Ini + Vector2(direccion_Dash * incremento, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos_Fin, tiempo)

func _process(delta: float) -> void:
	dano = cool_Down(delta)
	if atacado:
		vida -= 1
		print(vida)
		if vida <= 0:
			self.queue_free()
		else:
			atacado = false
	
func cool_Down(delta):
	t += delta
	cooldown = (1 - abs(cos(t))) * ataque
	if cooldown < ataque*.9:
		return 0
	else:
		t = 0.9
		cooldown = 0.9
		return ataque

func set_Atacado(status):
	atacado = status
