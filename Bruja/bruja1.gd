extends CharacterBody2D

@onready var bruja: Sprite2D = $bruja
@onready var anim_tree: AnimationTree = $bruja/AnimationTree

const SPEED = 80.0
const SPEED_TRANSFORMADA = 200.0
const DISTANCIA_TRANSFORMACION = 150.0
const DISTANCIA_ALCANZAR = 50.0

var personaje = null
var direccion = 0
var atacable : bool = false
var transformada : bool = false

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
			bruja.scale.x = 1 if direccion > 0 else -1
			
			# Activar animación de caminar
			anim_tree["parameters/walk/blend_amount"] = 1
		else:
			# Si está cerca, detener movimiento y activar animación de ataque
			velocity = Vector2.ZERO
			anim_tree["parameters/walk/blend_amount"] = 0
			anim_tree["parameters/Ataque/blend_amount"] = 1
	
	move_and_slide()

func _ready() -> void:
	personaje = get_parent().get_node("main_char")

func _on_area_entered(area):
	if area.is_in_group("main"):
		anim_tree["parameters/Blend2/blend_amount"] = 1

func verificar_transformacion(distancia: float) -> void:
	if distancia >= DISTANCIA_TRANSFORMACION and not transformada:
		transformarse()
	elif distancia <= DISTANCIA_ALCANZAR and transformada:
		regresar_estado_inicial()

func transformarse() -> void:
	transformada = true
	anim_tree["parameters/transformación/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	# Cambiar otros atributos o agregar efectos visuales para la transformación.

func regresar_estado_inicial() -> void:
	transformada = false
	anim_tree["parameters/Ataque/blend_amount"] = 1
