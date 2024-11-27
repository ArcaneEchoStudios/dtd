extends Node2D  # Or whatever your root node is
class_name CombatLog

var combat_log: RichTextLabel

func _ready():
    # Create and configure the RichTextLabel
    combat_log = RichTextLabel.new()
    # combat_log.rect_min_size = Vector2(400, 200)  # Set the initial size
    combat_log.scroll_active = true  # Enable scrolling
    combat_log.visible_characters = -1  # Show all characters immediately

    # Add the RichTextLabel to the scene tree
    add_child(combat_log)

    # Position the label (optional, if you want it centered)
    # combat_log.rect_position = Vector2(200, 200)

    # Test: Add a log entry
    add_log_entry("Combat log initialized!", Color.YELLOW)


func add_log_entry(entry: String, color: Color = Color.WHITE):
    combat_log.add_text("[color=%s]%s[/color]\n" % [color.to_html(), entry])
    combat_log.scroll_to_line(combat_log.get_line_count())