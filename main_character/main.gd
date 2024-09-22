extends CharacterBody2D
@onready var anim_tree: AnimationTree = $guerrera3/AnimationTree
@onready var sprite: Sprite2D = $guerrera3
const SPEED = 100.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("atack"):
		anim_tree["parameters/ATACKING/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		anim_tree["parameters/WALKING/blend_amount"] = 1
		sprite.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			anim_tree["parameters/WALKING/blend_amount"] = 0
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
