extends CharacterBody2D

@export var SPEED: int = 300
@export var playerhealth: int = 100
var attack_damage: int = 50

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var enemyhitbox: Area2D = $enemyhitbox
@onready var player_health_bar: ProgressBar = $PlayerHealthBar

var is_attacking: bool = false
var direction: Vector2 = Vector2.ZERO

var combo_step: int = 0
var combo_timer: float = 0.0
const COMBO_WINDOW: float = 1.5

func _ready() -> void:
	attack_area.monitoring = false
	attack_area.monitorable = false
	animated_sprite.animation_finished.connect(_on_attack_animation_finished)

func _physics_process(delta: float) -> void:
	handle_attack()
	update_combo_timer(delta)

	if not is_attacking:
		handle_movement()
		update_animation()

# ----------------------
# 🗡️ Attack
# ----------------------
func handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		combo_step += 1

		match combo_step:
			1:
				animated_sprite.play("attackone")
			2:
				animated_sprite.play("attacktwo")
			3:
				animated_sprite.play("attackthree")
			_:
				combo_step = 1
				animated_sprite.play("attackone")

		attack_area.monitoring = true
		attack_area.monitorable = true
		combo_timer = 0.0

func _on_attack_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		attack_area.monitoring = false
		attack_area.monitorable = false

# ----------------------
# 💥 Damage
# ----------------------
func take_damage(amount: int) -> void:
	playerhealth -= amount
	player_health_bar.value = playerhealth
	print("Remaining Health:", playerhealth)

# ----------------------
# ⏱️ Combo Timer
# ----------------------
func update_combo_timer(delta: float) -> void:
	if combo_step > 0:
		combo_timer += delta
		if combo_timer > COMBO_WINDOW:
			combo_step = 0
			combo_timer = 0.0

# ----------------------
# 🎮 Movement
# ----------------------
func handle_movement() -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	move_and_slide()

	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

# ----------------------
# 🎞️ Animation
# ----------------------
func update_animation() -> void:
	if direction == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")
