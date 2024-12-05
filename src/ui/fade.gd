extends CanvasItem  # Works with any 2D node and its children

signal fade_complete

# Fades in the given node (makes it visible gradually)
func fade_in(duration: float = 1.0) -> void:
    print('fading in')
    fade(0, 1, duration)

# Fades out the given node (makes it transparent gradually)
func fade_out(duration: float = 1.0) -> void:
    print ('fading out')
    fade(1, 0, duration)

func fade(from, to, duration):
    self.modulate.a = from 
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", to, duration)
    tween.connect('finished', Callable(self, 'emit_signal').bind('fade_complete'))