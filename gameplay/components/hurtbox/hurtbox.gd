class_name Hurtbox
extends Area2D


@export var actor : Character:
	get:
		if not actor:
			actor = get_parent()
		return actor


func take_damage(amount : float) -> void:
	actor.take_damage(amount)
