extends CharacterBody2D


var speed = 300.0
const JUMP_VELOCITY = -400.0

const IDLE = 'idle'
const STAND = 'stand'
const CROUCH = 'crouch'
const JUMPING = 'jumping'
const WALKING = 'walking'
const RISE = 'rise'
const LOOP_STATES = {
	STAND: null,
	WALKING: null,
	JUMPING: null,
}
const MAX_STANDING_COUNT = 10
var standing_count = MAX_STANDING_COUNT

var _state = STAND
var frozen = true

var state: String:
	get:
		return _state
	set(value):
		var prev = _state
		_state = value
		on_state_change(_state, prev)

var _direction = true
var direction: bool:
	get:
		return _direction
	set(value):
		var prev = _direction
		_direction = value
		if prev != _direction:
			on_direction_change(_direction, prev)

var _is_blocking = false
var is_blocking: bool:
	get:
		return _is_blocking
	set(value):
		var prev = _is_blocking
		_is_blocking = value
		if prev != _is_blocking:
			on_is_blocking_change(_is_blocking, prev)

var is_crouching = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	is_crouching = Input.is_action_pressed("ui_down")
	is_blocking = Input.is_action_pressed("block")
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# $StandCol.disabled = Input.is_action_pressed("ui_down")
	# $CrouchCol.disabled = not Input.is_action_pressed("ui_down")
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()
		standing_count = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x = Input.get_axis("ui_left", "ui_right")
	var direction_y = Input.get_axis("ui_down", "ui_up")
	
	if direction_x and not frozen:
		if is_on_floor():
			state = WALKING
		else:
			state = JUMPING
		standing_count = 0
		direction = direction_x < 0
		if not Input.is_action_pressed("ui_down"):
			velocity.x = direction_x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if not is_on_floor():
			state = JUMPING
		else:
			if Input.is_action_just_pressed("ui_down"):
				state = CROUCH
				standing_count = 0
			elif Input.is_action_just_released("ui_down"):
				state = RISE
			elif not Input.is_action_pressed("ui_down"):
				if standing_count >= MAX_STANDING_COUNT:
					state = IDLE
				elif LOOP_STATES.has(state) or not $AnimatedSprite2D.is_playing():
					state = STAND
					standing_count += 1

	move_and_slide()

func on_is_blocking_change(curr, prev):
	standing_count = 0
	state = state
		

func on_direction_change(curr, prev):
	$AnimatedSprite2D.flip_h = direction

func on_state_change(current, previous):
	var changed = current != previous
	match current:
		IDLE:
			frozen = false
			if is_blocking:
				$AnimatedSprite2D.play("block_stand")
			else:
				$AnimatedSprite2D.play("idle")
		STAND:
			if is_blocking:
				$AnimatedSprite2D.play("block_stand")
			else:
				$AnimatedSprite2D.play('stand')
		CROUCH:
			if is_blocking:
				$AnimatedSprite2D.play("block_crouch")
			else:
				if changed:
					$AnimatedSprite2D.play("crouching")
				else:
					$AnimatedSprite2D.play("crouching")
					$AnimatedSprite2D.frame_progress = 1
		RISE:
			if changed:
				$AnimatedSprite2D.play_backwards("crouching")
		WALKING:
			if changed:
				$AnimatedSprite2D.play('walking')
		JUMPING:
			if is_blocking:
				$AnimatedSprite2D.play("block_air")
			else:
				$AnimatedSprite2D.play("jumping")
			
	
