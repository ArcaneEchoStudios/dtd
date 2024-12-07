extends Node2D

var log_label: RichTextLabel

func _ready():
    # Create and configure the RichTextLabel directly
    log_label = RichTextLabel.new()
    log_label.custom_minimum_size = Vector2(300, 200)  # Set the size
    log_label.scroll_active = true  # Enable scrolling
    log_label.position = Vector2(50, 50)  # Place it directly on the screen
    add_child(log_label)

func add_log_entry(entry: String, color: Color = Color.WHITE):
    if log_label:
        log_label.push_color(color)
        log_label.append_text(entry + "\n")
        log_label.pop()
        log_label.scroll_to_line(log_label.get_line_count())
    