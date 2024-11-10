extends CharacterBody2D

#region nodes
@onready var sprite = $Sprite
@onready var collider = $Collider
@onready var animator = $Animator
#endregion

#region player movement variables

@export var RUN_SPEED = 150
@export var ACCELERATION = 40
@export var GRAVITY = 300
@export var JUMP_VELOCITY = -150
@export var MAX_JUMPS = 1

var move_speed = RUN_SPEED
var move_direction_x = 0
var jumps = 0
var is_facing_right = true

#endregion

#region input variables

var btn_up = false
var btn_down = false
var btn_left = false
var btn_right = false
var btn_jump = false
var btn_jump_just_pressed = false

#endregion

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# get inputs
	get_input_state()
	
	#handle movements
	handle_gravity(delta)
	handle_horizontal_movement()
	handle_jump()
	
	move_and_slide()
	handle_animation()
	
	print(position.x)

func get_input_state():
	btn_up = Input.is_action_pressed("btn_up")
	btn_down = Input.is_action_pressed("btn_down")
	btn_left = Input.is_action_pressed("btn_left")
	btn_right = Input.is_action_pressed("btn_right")
	btn_jump = Input.is_action_pressed("btn_jump")
	btn_jump_just_pressed = Input.is_action_just_pressed("btn_jump")
	
	if btn_right: is_facing_right = true
	if btn_left: is_facing_right = false

func handle_horizontal_movement():
	move_direction_x = Input.get_axis("btn_left", "btn_right")
	velocity.x = move_toward(velocity.x, move_direction_x * RUN_SPEED, ACCELERATION)

func handle_gravity(delta: float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		jumps = 0

func handle_jump():
	if btn_jump_just_pressed:
		velocity.y = JUMP_VELOCITY
		jumps += 1

func handle_animation():
	sprite.flip_h = !is_facing_right
	
	if is_on_floor():
		if velocity.x != 0:
			animator.play("run")
		else:
			animator.play("idle")
	else:
		if velocity.y < 0:
			animator.play("jump")
		else:
			animator.play("fall")
