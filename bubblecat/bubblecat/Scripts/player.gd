extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
@onready var progress_bar_left = $ProgressBarLeft
@onready var progress_bar_right = $ProgressBarRight

@export var slow_intensity: float
@export var slow_consumption: float 

const SPEED = 300.0
var slowdown_speed
var current_speed
var slowed: bool = false
var slow_meter: float = 1
var can_slow = true


func _ready():
	current_speed = SPEED
	slowdown_speed = SPEED/slow_intensity
	

func _process(delta: float) -> void:
	if 0 <= slow_meter and slow_meter < 1:
		progress_bar_left.set_visible(true)
		progress_bar_right.set_visible(true)
		
		progress_bar_left.value = slow_meter
		progress_bar_right.value = slow_meter

func _physics_process(delta: float) -> void:
	
	if slowed:
		slow_meter -= slow_consumption * delta
	else:
		slow_meter += slow_consumption * .75 * delta
		
	if	slow_meter <= 0:
		slow_meter = 0
		can_slow = false
	if slow_meter >= 1:
		progress_bar_left.set_visible(false)
		progress_bar_right.set_visible(false)
		slow_meter = 1
		can_slow = true
		

	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * current_speed
		if	direction.x > 0:
			animation.flip_h = false
		if direction.x < 0:
			animation.flip_h = true
		animation.play("run")
		
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.y = move_toward(velocity.y, 0, current_speed)
		animation.play("idle")

	move_and_slide()
	
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		if collision.get_collider().is_in_group("bubble"):
			queue_free()


func _input(event: InputEvent) -> void:
	if	event.is_action_pressed("slow") and can_slow:
		slowed = true
		Engine.time_scale = slow_intensity
		current_speed = slowdown_speed
		
	if	event.is_action_released("slow") or !can_slow:
		slowed = false
		Engine.time_scale = 1
		current_speed = SPEED
