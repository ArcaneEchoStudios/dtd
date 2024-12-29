extends CharacterBase

class_name Runner

#const ZombiClass = preload("res://scenes/zombi-runner/Scenes/zombi.gd")

func get_input() -> Vector2:
    if state == CharacterState.DYING:
        return Vector2.ZERO

    var input_vector = Vector2(Input.get_axis("player_left_a", "player_right_a"),
            Input.get_axis("player_up_a", "player_down_a"))

    return input_vector.normalized()

func get_eaten() -> void:
    change_state(CharacterState.DYING)

    return

func _on_character_checker_area_entered(area: Area2D) -> void:
    if area.get_parent() is Zombi:
        print("GETTING EATEN!")
        get_eaten()
