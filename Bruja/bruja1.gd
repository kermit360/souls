extends CharacterBody2D
@onready var bruja: Sprite2D = $bruja
@onready var anim_tree: AnimationTree = $bruja/AnimationTree

const SPEED = 80.0
var personaje = null
var direccion = 0
var atacable : bool = false

func _physics_process(delta: float) -> void:
	# Añadir gravedad.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		var position_objetivo = Vector2(personaje.position.x, self.position.y)
		
		if 50 < position.distance_to(position_objetivo) and position.distance_to(position_objetivo) < 200:
			# Calcular dirección y movimiento
			if personaje.position.x == self.position.x:
				direccion = 0
				velocity = Vector2.ZERO
				anim_tree["parameters/walk/blend_amount"] = 0
			else:
				direccion = position.direction_to(position_objetivo).x
				velocity = position.direction_to(position_objetivo) * SPEED
				if direccion > 0:
					bruja.scale.x = 1
					
				else:
					bruja.scale.x = -1
			print(direccion)
			# Ajustar la escala del sprite según la dirección
			
			# Activar animación de caminar
			anim_tree["parameters/walk/blend_amount"] = 1
		elif position.distance_to(position_objetivo) >= 200:
			# Configurar animación en idle si está fuera del rango
			velocity = Vector2.ZERO
			anim_tree["parameters/walk/blend_amount"] = 0
			velocity = Vector2.ZERO
			anim_tree["parameters/Ataque/blend_amount"] = 0
		elif position.distance_to(position_objetivo) < 50:
			velocity = Vector2.ZERO
			anim_tree["parameters/Ataque/blend_amount"] = 1
			
	
	move_and_slide()

func _ready() -> void:
	personaje = get_parent().get_node("main_char")

func _on_area_entered(area):
	if area.is_in_group("main"):
		anim_tree["parameters/Blend2/blend_amount"] = 1

func _process(delta: float) -> void:
	if atacable:
		anim_tree["parameters/ataque/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		atacable = false
