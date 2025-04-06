extends TextureProgressBar

@onready var real_bar: TextureProgressBar = $RealBar

func on_health_changed(hp, max):
	value = real_bar.value
	var val = (hp / max) * 100.0
	create_tween().tween_property(real_bar, "value", val, 0.2).set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(1.0).timeout
	create_tween().tween_property(self, "value", val, 2.0)
