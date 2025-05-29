extends CharacterBody2D

@export var SPEED = 300
var attack_damage = 50
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

var is_attacking = false
var direction := Vector2.ZERO

func _ready() -> void:
	attack_area.monitoring = false
	attack_area.monitorable = false

func _physics_process(delta: float) -> void:
	handle_attack()
	if is_attacking:
		return
	
	handle_movement()
	update_animation()

# ------------------
# 🗡️ Attack
# ------------------
func handle_attack():
	if Input.is_action_just_pressed("attack") and !is_attacking:
		is_attacking = true
		animated_sprite_2d.play("attack")
		attack_area.monitoring = true
		attack_area.monitorable = true

	elif is_attacking and animated_sprite_2d.animation == "attack" and animated_sprite_2d.frame >= 5:
		is_attacking = false
		attack_area.monitoring = false
		attack_area.monitorable = false

# ------------------
# 🕹️ Movements
# ------------------
func handle_movement() -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	if direction.x != 0:
		animated_sprite_2d.flip_h = direction.x < 0

# ------------------
# 🎞️ Animations
# ------------------
func update_animation():
	if direction == Vector2.ZERO:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")
