extends Node2D
const Character = preload("res://src/character.gd")
const Action = preload("res://src/action.gd")
const Clock = preload("res://src/clock.gd")
const Planner = preload("res://src/planner.gd")
var CombatLog = preload("res://src/combat_log.gd").new()


var warrior = Character.new("Warrior", Color.RED, "left", 1, true)
var mage = Character.new("Mage", Color.CYAN, "left", 2, true)
var rogue = Character.new("Rogue", Color.GREEN, "middle", 1, true)
var zombie = Character.new("Zmobie", Color.BLACK, "middle", 2, false)
var necro = Character.new("Necro", Color.PURPLE, "right", 1, false)
var characters = [warrior, mage, rogue, zombie, necro]
var clock: Clock
var stepping: bool = false

func _on_clock_ticked():
    if stepping: 
        return
    
    await turn_time()
    plan_enemies()

func _ready() -> void:
    clock = Clock.new(512, 412, 100, 7)
    add_child(clock)
    clock.connect("clock_event", Callable(self, "_on_clock_ticked"))

    CombatLog.position = Vector2(10, 650)
    add_child(CombatLog)

    CombatLog.add_log_entry("Starting combat...", Color.WHITE);
    

    CombatLog.add_log_entry("Loading characters from character sheet...", Color.WHITE);
    warrior.add_action(Action.new("Grapple", 0, "Prevent enemy movement this turn"))
    warrior.add_action(Action.new("Cleave", 3, "Attack all enemies in your zone"))
    mage.add_action(Action.new("Fireball", 5, "Deal all the damage to any zone"))
    mage.add_action(Action.new("Magic Missile", 1, "Deal 3 damage to any targets"))
    rogue.add_action(Action.new("Hide", 1, "Move into stealth"))
    rogue.add_action(Action.new("Stab", 1, "Move from stealth to any zone. Attack"))

    
    CombatLog.add_log_entry("Creating minions...", Color.WHITE);
    zombie.add_action(Action.new("Bite", 1, "Attack successful. Target `infected`"))
    necro.add_action(Action.new("Raise", 4, "New Zombie created"))
    for i in range(characters.size()):
        var ch = characters[i]
        add_child(ch)  # Add the token to the scene tree
        ch.position = $Zones.get_node(ch.zone).position + Vector2(20, ch.slot * 20)

    plan_action(zombie, "Bite")
    plan_action(zombie, "Move")
    plan_action(necro, "Move")
    plan_action(necro, "Raise")

    CombatLog.add_log_entry("Enemies ready...", Color.WHITE);

    var pcs = [warrior, rogue, mage]

    for i in range(pcs.size()):
        var ch = pcs[i]
        var on_action = Callable(self, "plan_action")
        var p = Planner.new(ch, on_action)
        p.position = Vector2(400 + (200 * i), 700)
        $Planner.add_child(p)


func plan_action(ch: Character, action_name: String):
    var action = ch.get_action(action_name)
    clock.plan_step(ch, action)
    clock.queue_redraw()


func turn_time():    
    stepping = true
    CombatLog.add_log_entry("Turning time")
    clock.steps.pop_front()
    clock.steps.append([])
    clock.queue_redraw()

    while clock.steps[0].size() > 0:
        var character: Character = clock.steps[0][0][0]
        var action: Action = clock.steps[0][0][1]
        CombatLog.add_log_entry("\t %s used %s!" % [character.ch_name, action.name], character.color)
        await get_tree().create_timer(1.0).timeout
        # CombatLog.add_log_entry("\t\t %s" % [action.effect], character.color)
        clock.steps[0].pop_front()
        clock.queue_redraw()
    stepping = false

func plan_enemies():
    for ch in characters:
        if not ch.is_pc:
            plan_action(ch, "__random__")
    CombatLog.add_log_entry("Enemies planned")