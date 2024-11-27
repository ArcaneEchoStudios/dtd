extends Node2D
const Character = preload("res://src/character.gd")
const Action = preload("res://src/action.gd")
const Clock = preload("res://src/clock.gd")
var CombatLog = preload("res://src/combat_log.gd").new()

var characters = [
    Character.new("Warrior", Color.RED, "left", 1, true),
    Character.new("Mage", Color.BLUE, "left", 2, true),
    Character.new("Rogue", Color.GREEN, "middle", 1, true),
    Character.new("Zmobie", Color.WHITE, "middle", 2, false),
    Character.new("Necro", Color.PURPLE, "right", 1, false)
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_child(CombatLog)
    CombatLog.position = Vector2(0, 400)
    var clock = Clock.new(512, 512, 128, 7)
    add_child(clock)

    clock.connect("clock_event",  Callable(self, "_on_clock_ticked"))
    
    CombatLog.add_log_entry("Starting combat...", Color.WHITE);
    characters[0].add_action(Action.new("Grapple", 0, "Enemies cannot `Move` from your zone"))
    characters[0].add_action(Action.new("Cleave", 3, "Attack all enemies in your zone"))
    characters[1].add_action(Action.new("Fireball", 5, "Deal sideways-8 damage to a whole zone"))
    characters[1].add_action(Action.new("Magic Missile", 1, "Deal 3 damage to any targets"))
    characters[2].add_action(Action.new("Hide", 1, "Move into stealth"))
    characters[2].add_action(Action.new("Stab", 1, "Move into any zone and make an attack (requires stealth)"))
    characters[3].add_action(Action.new("Bite", 1, "Attack and `infect`"))
    characters[4].add_action(Action.new("Raise", 4, "Create a zombie in any zone"))
    for i in range(characters.size()):
        var ch = characters[i]
        add_child(ch)  # Add the token to the scene tree
        ch.position = $Zones.get_node(ch.zone).position + Vector2(20, ch.slot * 20)

    CombatLog.add_log_entry("Characters loaded...", Color.WHITE);


    clock.add_step(1, characters[3], characters[3].get_action("Bite"))
    clock.add_step(2, characters[3], characters[3].get_action("Move"))
    clock.add_step(1, characters[4], characters[4].get_action("Move"))
    clock.add_step(4, characters[4], characters[4].get_action("Raise"))

    CombatLog.add_log_entry("Enemy Actions Set...", Color.WHITE);


func _on_clock_ticked(event_type, value):
    CombatLog.add_log_entry("Clock Clicked", Color.RED);