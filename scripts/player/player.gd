class_name Player
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var coyote_timer = $CoyoteTimer

@export_group("Player movement")
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var NUMBER_OF_EXTRA_JUMPS: int = 1
@export var COYOTE_FRAMES: int = 6

var jumping = true
var number_of_jumps_left = NUMBER_OF_EXTRA_JUMPS	

var coyote = false
var last_floor = false

func _ready() -> void:
	coyote_timer.wait_time = COYOTE_FRAMES / float(Engine.physics_ticks_per_second)

func _physics_process(delta: float) -> void:
	if get_parent().generation_mode:
		return
	
	if !is_on_floor() and last_floor and !jumping:
		coyote = true
		coyote_timer.start()
		print("coyote time!", $CoyoteTimer.time_left)
	
	last_floor = is_on_floor()
	
	# print("coyote: %s, jumping: %s, last_floor: %s" % [coyote, jumping, last_floor])
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if is_on_floor():
		number_of_jumps_left = NUMBER_OF_EXTRA_JUMPS;
		jumping = false
		coyote_timer.stop()
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or number_of_jumps_left > 0 or coyote):
		velocity.y = JUMP_VELOCITY
		
		if (!coyote && !is_on_floor()):
			number_of_jumps_left -= 1
			
		jumping = true

	# get direction
	var direction := Input.get_axis("move_left", "move_right")

	# flip sprite	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if direction:
		velocity.x = direction * SPEED
		$TrailParticles.emitting = true
		if is_on_floor():
			$DustParticles.emitting = true
		else:
			$DustParticles.emitting = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$TrailParticles.emitting = false
		$DustParticles.emitting = false
		
	
	# play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	#TODO: this is naive, should probably move to game.gd instead	
	var bgMap = get_node("../Level/ParallaxMap");
	
	if bgMap != null:
		bgMap.position = -0.1 * position

	move_and_slide()


func _on_coyote_timer_timeout() -> void:
	coyote = false
	print("coyote time off!")
