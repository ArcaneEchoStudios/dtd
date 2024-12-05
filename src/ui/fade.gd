extends CanvasItem  # Works with any 2D node and its children

# Fades in the given node (makes it visible gradually)
func fade_in(duration: float = 1.0) -> void:
    if self.modulate.a == 1:
        return
    print('fading in')
    self.modulate.a = 0  # Ensure fully transparent
    create_tween().tween_property(self, "modulate:a", 1.0, duration)

# Fades out the given node (makes it transparent gradually)
func fade_out(duration: float = 1.0) -> void:
    if self.modulate.a == 0:
        return
    print('fading out')
    self.modulate.a = 1 
    create_tween().tween_property(self, "modulate:a", 0.0, duration)
