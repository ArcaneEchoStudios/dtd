extends Node2D
const Character = preload("res://src/character.gd")
const Action = preload("res://src/action.gd")
const Clock = preload("res://src/clock.gd")
const Planner = preload("res://src/planner.gd")
var CombatLog = preload("res://src/combat_log.gd").new()

var characters = [
    Character.new("Warrior", Color.RED, "left", 1, true),
    Character.new("Mage", Color.BLUE, "left", 2, true),
    Character.new("Rogue", Color.GREEN, "middle", 1, true),
    Character.new("Zmobie", Color.BLACK, "middle", 2, false),
    Character.new("Necro", Color.PURPLE, "right", 1, false)
]
var clock: Clock
var stepping: bool = false

func _on_clock_ticked():
    if stepping: 
        return
    
    await turn_time()
    plan_enemies()

func _ready() -> void:
    clock = Clock.new(512, 512, 128, 7)
    add_child(clock)
    clock.connect("clock_event", Callable(self, "_on_clock_ticked"))

    CombatLog.position = Vector2(0, 400)
    add_child(CombatLog)

    CombatLog.add_log_entry("Starting combat...", Color.WHITE);

    
    CombatLog.add_log_entry("Loading characters from character sheet...", Color.WHITE);
    characters[0].add_action(Action.new("Grapple", 0, "Enemies cannot `Move` from your zone"))
    characters[0].add_action(Action.new("Cleave", 3, "Attack all enemies in your zone"))
    characters[1].add_action(Action.new("Fireball", 5, "Deal sideways-8 damage to a whole zone"))
    characters[1].add_action(Action.new("Magic Missile", 1, "Deal 3 damage to any targets"))
    characters[2].add_action(Action.new("Hide", 1, "Move into stealth"))
    characters[2].add_action(Action.new("Stab", 1, "Move into any zone and make an attack (requires stealth)"))

    
    CombatLog.add_log_entry("Creating minions...", Color.WHITE);
    characters[3].add_action(Action.new("Bite", 1, "Attack successful. Target `infected`"))
    characters[4].add_action(Action.new("Raise", 4, "New Zombie created"))
    for i in range(characters.size()):
        var ch = characters[i]
        add_child(ch)  # Add the token to the scene tree
        ch.position = $Zones.get_node(ch.zone).position + Vector2(20, ch.slot * 20)

    var zombie = characters[3]
    var necro = characters[4]
    plan_action(zombie, "Bite")
    plan_action(zombie, "Move")
    plan_action(necro, "Move")
    plan_action(necro, "Raise")

    CombatLog.add_log_entry("Enemies ready...", Color.WHITE);

func plan_action(ch: Character, action_name: String):
    var action = ch.get_action(action_name)
    clock.plan_step(ch, action)


func turn_time():
    # This is the list of steps that need to happen (1 is next turn)
    
    stepping = true
    CombatLog.add_log_entry("Turning time")
    clock.steps.pop_front()
    clock.steps.append([])
    clock.queue_redraw()

    while clock.steps[0].size() > 0:
        var character: Character = clock.steps[0][0][0]
        var action: Action = clock.steps[0][0][1]
        CombatLog.add_log_entry("\t %s uses %s..." % [character.ch_name, action.name], character.color)
        await get_tree().create_timer(1.0).timeout
        CombatLog.add_log_entry("\t\t %s" % [action.effect], character.color)
        clock.steps[0].pop_front()
        clock.queue_redraw()
    stepping = false

func plan_enemies():
    for ch in characters:
        if not ch.is_pc:
            plan_action(ch, "__random__")
    CombatLog.add_log_entry("Enemies planned")