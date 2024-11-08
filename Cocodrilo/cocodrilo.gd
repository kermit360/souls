extends CharacterBody2D
@onready var bruja: Sprite2D = $EnemigoAvanzado
@onready var anim_tree: AnimationTree = $EnemigoAvanzado/AnimationTree

const SPEED = 80.0
var personaje = null
var direccion = 0
var dano = 3

func _physics_process(delta: float) -> void:
	# Añadir gravedad.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if 100 < position.distance_to(personaje.position) and position.distance_to(personaje.position) < 200:
			# Calcular dirección y movimiento
			velocity = position.direction_to(personaje.position) * SPEED
			direccion = position.direction_to(personaje.position).x
			
			# Ajustar la escala del sprite según la dirección
			bruja.scale.x = 1 if direccion > 0 else -1
			
			# Activar animación de Caminar
			anim_tree["parameters/Caminar/blend_amount"] = 1
		elif  position.distance_to(personaje.position) < 80:
			anim_tree["parameters/Ataque/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			emit_signal("ataco", dano)
		elif 200 < position.distance_to(personaje.position) :
			# Configurar animación en idle si está fuera del rango
			velocity = Vector2.ZERO
			anim_tree["parameters/Caminar/blend_amount"] = 0
	move_and_slide()

func _ready() -> void:
	personaje = get_parent().get_node("main_char")

	
