class_name Hitbox
extends Area2D


@export var actor : Character:
	get:
		if not actor:
			actor = get_parent()
		return actor


func _on_hurtbox_detected(hurtbox : Hurtbox) -> void:
	if hurtbox.actor == actor: # No self-harm here folks
		return
	hurtbox.take_damage(actor.damage)
