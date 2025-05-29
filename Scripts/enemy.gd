extends Node2D

@export var max_health: int = 100
var current_health: int

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Area2D
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	current_health = max_health
	hitbox.connect("area_entered", _on_hitbox_area_entered)
	animated_sprite.play("idle")
	animated_sprite.animation_finished.connect(_on_animation_finished)

#Get Attack Damage From player.gd and hit func
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		var player = area.get_parent()
		var damage: int = 0
		
		if player.has_method("get_attack_damage"):
			damage = player.get_attack_damage()
		elif "attack_damage" in player:
			damage = player.attack_damage
		
		current_health -= damage
		health_bar.value -= 50
		print_debug("New Enemy Health: ", current_health)
		
		if current_health <= 0:
			current_health = 0
			animated_sprite.play("hit")
			
#Enemy dissapears
func _on_animation_finished() -> void:
	if animated_sprite.animation == "hit":
		queue_free()
