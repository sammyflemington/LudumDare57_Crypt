extends Area2D

@export var player: Player

var loot_touching = []

func _on_body_entered(body: Node2D) -> void:
	if body is LootDrop:
		loot_touching.append(body)


func _on_body_exited(body: Node2D) -> void:
	if body in loot_touching:
		loot_touching.erase(body)

func _process(dt):
	for loot in loot_touching:
		if loot.can_pick_up:
			player.gain_loot(loot.loot_id)
			loot.queue_free()
