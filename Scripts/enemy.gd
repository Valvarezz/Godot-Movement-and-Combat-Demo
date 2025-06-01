extends Node2D

@export var max_health: int = 100
var current_health: int = max_health
var is_blowing: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $enemyhitbox
@onready var healthbar: ProgressBar = $HealthBar
@onready var enemyhitbox: Area2D = $enemyhitbox
@onready var blowuparea: Area2D = $blowuparea
@onready var explosion: AnimatedSprite2D = $explosion

func _ready() -> void:
	hitbox.connect("area_entered", _on_hitbox_area_entered)
	enemyhitbox.connect("area_entered", _on_enemyhitbox_area_entered)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("idle")
	explosion.visible = false

# ----------------------
# Player touches Enemy TNT
# ----------------------
func _on_enemyhitbox_area_entered(area: Area2D) -> void:
	if area.name == "playerhitbox":
		print("Player is in enemyhitbox area")
		is_blowing = true

		var player = area.get_parent()

		# blowup and explosion animation
		animated_sprite.play("blowup")
		await animated_sprite.animation_finished
		explosion.visible = true
		explosion.play("explosion")
		await explosion.animation_finished
		State.enemy_alive = "dead"

		# Check if player is still inside blowup area
		var overlapping_areas = blowuparea.get_overlapping_areas()
		for overlap in overlapping_areas:
			if overlap.name == "playerhitbox":
				if player.has_method("take_damage") and current_health > 0:
					player.take_damage(50)
				break

		queue_free()
# ----------------------
# Taken hit by Player
# ----------------------
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name != "AttackArea":
		return

	var player = area.get_parent()
	var damage: int = 0

	if player.has_method("get_attack_damage"):
		damage = player.get_attack_damage()
	elif "attack_damage" in player:
		damage = player.attack_damage

	if not is_blowing:
		animated_sprite.play("hit")

	current_health -= damage
	healthbar.value = current_health
	print_debug("New Enemy Health: ", current_health)

	if current_health <= 0:
		State.enemy_alive = "dead"
		print_debug("Enemy died")
		queue_free()

# Handle animation transitions
func _on_animation_finished() -> void:
	if animated_sprite.animation == "hit":
		animated_sprite.play("idle")
