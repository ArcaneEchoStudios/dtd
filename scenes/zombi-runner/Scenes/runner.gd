extends "res://scenes/zombi-runner/Scenes/character.gd"

func get_input() -> Vector2:
    var input_vector = Vector2(Input.get_axis("player_left_a", "player_right_a"),
            Input.get_axis("player_up_a", "player_down_a"))

    return input_vector.normalized()
