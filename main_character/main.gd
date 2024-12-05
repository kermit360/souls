extends CharacterBody2D

# Logica Elementos
@onready var anim_treeR: AnimationTree = $guerrero_2/AnimationTree
@onready var anim_treeL: AnimationTree = $guerrero_2L/AnimationTree
@onready var spear: RayCast2D = $RayCast2D

@onready var spriteR: Sprite2D = $guerrero_2
@onready var spriteL: Sprite2D = $guerrero_2L

@onready var sangr_enem: GPUParticles2D = $sangr_enem


var sangr_enem_loc = 0


var dash_cooldown_timer: float = 0.0
const DASH_COOLDOWN: float = 5.0


# Logica Animaciones
enum {
	IDLE, IDLE_DEF, #IDLES
	RUN, ANIM_UP, ANIM_DOWN, #MOVEMENTS
	}
var current_animation = IDLE
var CROUCHED : bool = false 
var ultima_Direccion = 1

#Logica Fisicas
var SPEED : float = 200.0
var JUMP_VELOCITY : float = -400.0

# Logica Ataques
var objeto_Atacado = null
var sprite_material = null

#Logica Vida
const vida_Ori = 10.0
var vida = vida_Ori

var ultimo_Ataque_Left = true
enum {
	vivo, moribundo, muerto
}
var current_Live_State = vivo
var ataque_Recibido = 0



func _ready() -> void:
	sprite_material = spriteR.material
	sangr_enem_loc = sangr_enem.position.x

func _process(delta):
	Animation_Handler()
	Dead_Handler()
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta



func _physics_process(delta: float) -> void:
	#gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	#salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not CROUCHED:
		$brinco.play()
		anim_treeR["parameters/JUMP/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		anim_treeL["parameters/JUMP/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		await get_tree().create_timer(0.5).timeout
		velocity.y = JUMP_VELOCITY

	#ataque
	if Input.is_action_just_pressed("atack"):
		if is_on_floor():
			anim_treeR["parameters/ATACK/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			anim_treeL["parameters/ATACK/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		else:
			anim_treeR["parameters/ATTACK2/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			anim_treeL["parameters/ATTACK2/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		if not CROUCHED and not current_Live_State == muerto:
			dash_Animation(ultima_Direccion, 10, .5)
		

		if spear.is_colliding():
			objeto_Atacado = spear.get_collider()
			if objeto_Atacado.is_in_group("Atacable"):
				objeto_Atacado.set_Atacado(true)
				sangr_enem.emitting = true
				$lanza_ataque.play()
		else:
			$lanza.play()

	#defensa
	if Input.is_action_just_pressed("defend") and not CROUCHED:
		anim_treeR["parameters/DEFENSE/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		anim_treeL["parameters/DEFENSE/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	#desplazamento
	var direction := Input.get_axis("left", "right")

	# crouch
	if Input.is_action_just_pressed("crouch"):
		anim_treeR["parameters/CROUCH/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		anim_treeL["parameters/CROUCH/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	if Input.is_action_pressed("crouch"):
		CROUCHED = true
		SPEED = 100
	if Input.is_action_just_released("crouch"):
		CROUCHED = false
		SPEED = 200

	# dash
	if Input.is_action_just_pressed("dash") and not CROUCHED and not current_Live_State == muerto and dash_cooldown_timer <= 0:
		$dash.play()
		anim_treeR["parameters/DASH/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		anim_treeL["parameters/DASH/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		dash_Animation(ultima_Direccion, 120, .5)
		dash_cooldown_timer = DASH_COOLDOWN
	
	if Input.is_action_just_released("dash"):
		pass
		
	if direction != 0 and current_Live_State != muerto:
		ultima_Direccion = direction
		velocity.x = direction * SPEED
		
		if direction < 0:
			$guerrero_2L.visible = true
			$guerrero_2.visible = false
			$RayCast2D.target_position.x = -51
			sprite_material = spriteL.material
			sangr_enem.position.x = -sangr_enem_loc
			
		else:
			$guerrero_2L.visible = false
			$guerrero_2.visible = true
			$RayCast2D.target_position.x = 51
			sprite_material = spriteR.material
			sangr_enem.position.x = sangr_enem_loc
			

			
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	#suelo
	if is_on_floor():
		if velocity.x != 0:
			current_animation = RUN
			if not $run.playing:
				$run.play()
			
		else:
			if $run.playing:
				$run.stop()
			current_animation = IDLE
			if Input.is_action_pressed("defend") and not CROUCHED:
				current_animation = IDLE_DEF
	#aire
	else:
		if $run.playing:
			$run.stop()
		if velocity.y>0:
			current_animation = ANIM_DOWN
		else:
			current_animation = ANIM_UP
		if direction == 0:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()

func Animation_Handler():
	if not current_Live_State == muerto:
		match current_animation:
			IDLE:
				if CROUCHED == false:
					anim_treeR["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeR["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_treeR["parameters/RUN/blend_amount"] = 0
					anim_treeR["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_treeR["parameters/AIR_UP/blend_amount"] = 0
					anim_treeR["parameters/AIR_DOWN/blend_amount"] = 0
					
					anim_treeL["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeL["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_treeL["parameters/RUN/blend_amount"] = 0
					anim_treeL["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_treeL["parameters/AIR_UP/blend_amount"] = 0
					anim_treeL["parameters/AIR_DOWN/blend_amount"] = 0
				else:
					anim_treeR["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeR["parameters/CROUCH_IDLE/blend_amount"] = 1
					anim_treeR["parameters/RUN/blend_amount"] = 0
					anim_treeR["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_treeR["parameters/AIR_UP/blend_amount"] = 0
					anim_treeR["parameters/AIR_DOWN/blend_amount"] = 0
					
					anim_treeL["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeL["parameters/CROUCH_IDLE/blend_amount"] = 1
					anim_treeL["parameters/RUN/blend_amount"] = 0
					anim_treeL["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_treeL["parameters/AIR_UP/blend_amount"] = 0
					anim_treeL["parameters/AIR_DOWN/blend_amount"] = 0
			IDLE_DEF:
				anim_treeR["parameters/IDLE_DEF/blend_amount"] = 1
				anim_treeR["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_treeR["parameters/RUN/blend_amount"] = 0
				anim_treeR["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_treeR["parameters/AIR_UP/blend_amount"] = 0
				anim_treeR["parameters/AIR_DOWN/blend_amount"] = 0
				
				anim_treeL["parameters/IDLE_DEF/blend_amount"] = 1
				anim_treeL["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_treeL["parameters/RUN/blend_amount"] = 0
				anim_treeL["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_treeL["parameters/AIR_UP/blend_amount"] = 0
				anim_treeL["parameters/AIR_DOWN/blend_amount"] = 0
			RUN:
				if CROUCHED == false:
					anim_treeR["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeR["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_treeR["parameters/RUN/blend_amount"] = 1
					anim_treeR["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_treeR["parameters/AIR_UP/blend_amount"] = 0
					anim_treeR["parameters/AIR_DOWN/blend_amount"] = 0
					
					anim_treeL["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeL["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_treeL["parameters/RUN/blend_amount"] = 1
					anim_treeL["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_treeL["parameters/AIR_UP/blend_amount"] = 0
					anim_treeL["parameters/AIR_DOWN/blend_amount"] = 0
				else:
					anim_treeR["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeR["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_treeR["parameters/RUN/blend_amount"] = 0
					anim_treeR["parameters/CROUCH_MOVE/blend_amount"] = 1
					anim_treeR["parameters/AIR_UP/blend_amount"] = 0
					anim_treeR["parameters/AIR_DOWN/blend_amount"] = 0
					
					anim_treeL["parameters/IDLE_DEF/blend_amount"] = 0
					anim_treeL["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_treeL["parameters/RUN/blend_amount"] = 0
					anim_treeL["parameters/CROUCH_MOVE/blend_amount"] = 1
					anim_treeL["parameters/AIR_UP/blend_amount"] = 0
					anim_treeL["parameters/AIR_DOWN/blend_amount"] = 0
			ANIM_UP:
				anim_treeR["parameters/IDLE_DEF/blend_amount"] = 0
				anim_treeR["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_treeR["parameters/RUN/blend_amount"] = 0
				anim_treeR["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_treeR["parameters/AIR_UP/blend_amount"] = 1
				anim_treeR["parameters/AIR_DOWN/blend_amount"] = 0
				
				anim_treeL["parameters/IDLE_DEF/blend_amount"] = 0
				anim_treeL["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_treeL["parameters/RUN/blend_amount"] = 0
				anim_treeL["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_treeL["parameters/AIR_UP/blend_amount"] = 1
				anim_treeL["parameters/AIR_DOWN/blend_amount"] = 0
			ANIM_DOWN:
				anim_treeR["parameters/IDLE_DEF/blend_amount"] = 0
				anim_treeR["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_treeR["parameters/RUN/blend_amount"] = 0
				anim_treeR["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_treeR["parameters/AIR_UP/blend_amount"] = 0
				anim_treeR["parameters/AIR_DOWN/blend_amount"] = 1
				
				anim_treeL["parameters/IDLE_DEF/blend_amount"] = 0
				anim_treeL["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_treeL["parameters/RUN/blend_amount"] = 0
				anim_treeL["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_treeL["parameters/AIR_UP/blend_amount"] = 0
				anim_treeL["parameters/AIR_DOWN/blend_amount"] = 1

func Dead_Handler():
	if vida > 5.0:
		current_Live_State = vivo
	elif 0 < vida and vida <= 5.0:
		current_Live_State = moribundo
	elif vida <= 0.0:
		current_Live_State = muerto
		SPEED = 0
		JUMP_VELOCITY = 0
		if ultimo_Ataque_Left:
			anim_treeR["parameters/DEAD/blend_amount"] = -1
			anim_treeL["parameters/DEAD/blend_amount"] = -1
		else:
			anim_treeR["parameters/DEAD/blend_amount"] = 1
			anim_treeL["parameters/DEAD/blend_amount"] = 1

func dash_Animation(direccion, incremento, tiempo):
	var pos_Ini = position
	var pos_Fin = pos_Ini + Vector2(direccion * incremento, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos_Fin, tiempo)

func dano_Recibido(dano, direccion_Ataque):
	if current_animation==IDLE_DEF and not current_Live_State == muerto and dano>0:
		$escudo.play()
		dash_Animation(direccion_Ataque, 3, .1)
		
	if not current_animation == IDLE_DEF and not current_Live_State == muerto:
		if dano>0:
			$agh.play()
			sprite_material.set_shader_parameter("enabled", true)
			dash_Animation(direccion_Ataque, 5, .2)
			if direccion_Ataque * ultima_Direccion > 0:
				anim_treeR["parameters/ATA_RES_2/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
				anim_treeL["parameters/ATA_RES_2/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		
			else:
				anim_treeR["parameters/ATA_RES/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
				anim_treeL["parameters/ATA_RES/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		
			print("dano recibido: ", dano, ",  con direccion: ", direccion_Ataque)
		else:
			sprite_material.set_shader_parameter("enabled", false)
		ataque_Recibido = dano
		vida -= dano
		if direccion_Ataque * ultima_Direccion > 0:
			ultimo_Ataque_Left = false
		else:
			ultimo_Ataque_Left = true

func set_Vida_Recuperada(cantidad):
	vida += cantidad
	print("vida +", cantidad)
