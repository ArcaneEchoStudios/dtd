class_name Action  # Makes it globally accessible

# Properties
var name: String
var time: int
var effect: String

# Constructor
func _init(name: String, time: int, effect: String) -> void:
    self.name = name
    self.time = time
    self.effect = effect
