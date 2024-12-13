# nonsense placeholder name

## Concept

You (the player) are a hero who works for the guild of royal adventures. You will choose quests, explore the area around your assigned fortification, fight monsters, defend the helpless, and generally do heroic things.

### Core Game Loop

- Player chooses one of n (probably 3) quests. 
    
- Player ‘wakes up’ (start of day)
    
- Player chooses what companions the hero will bring. 
    
- Player chooses what equipment the hero and companions will bring.
    
- The player will now have a deck that they can see the contents of. The cards are added based on the above three choices. 
    
- Player then chooses a location on the map to conduct adventure
    
- Player plays out their adventure using their cards. In peaceful situations, player will gather resources or move narrative forward. In combat situations, the player will attempt to overcome the adversary. Cards will interact with peaceful or combat situations, and sometimes both. 
    
- Once deck is exhausted or player is on the losing end of a fight, the player returns home with any further resources gathered or loot obtained.
    
- Back home at the player's fortification, the player can spend resources or money to repair and recover (economy drain), buy new supplies or gear, and invest in the fortification or surrounding infrastructure.
    
- Once in a while, before starting the loop over again, there will be an event. These will have many different applications, but the fortification getting attacked is how we introduce the fail state.
    
- The next day, the player starts the loop over again.
    

### Game Systems and Mechanics

- Quests
    

- Give the player options that incentivize player towards interacting with the game systems
    
- Options will loosely describe the type of terrain, combat, or tasks involved. Helping the player to choose something they're optimized to handle.
    
- Choice and outcome affect a measure of some sort. Like Notoriety or Reputation.
    

- Map
    

- Map is generated randomly at the beginning of the game. Think a node map like Slay the Spire, but with a spiderweb shape and a fog of war, obscuring details of the map further away from the center.
    
- Hero's fortification is at the center of the map. There are choices of places to go for any given day's adventure. New choices light up like a spiderweb based on previously explored locations, game events, and more
    
- Player can see where to go to accomplish their quest, and sometimes see information about the terrain, adversaries, fortifications, etc
    

- Hero
    

- Player  character navigates the core game loop and leads their companions to victory
    
- Player has a health pool (or maybe use the deck) and when this pool empties their adventure is over. Maybe they're saved by a silly medieval drawing of an animal.
    
- Player carries something in each hand (usually a weapon and a tool) and wears a set of armor.
    

- Companions
    

- Has properties that reward synergistic choices or counter play choices. For example, a Lumberjack companion using an axe in a forest might get more lumber from harvesting and still be able to fight if monsters show up. Or a Herbalist might make you immune to poison, allowing you to more easily navigate swamps.
    
- Each carries something in each hand (typically a weapon and a tool) and wears a set of armor.
    

- Equipment
    

- Weapons primarily add attack cards to the deck. A simple short sword might do "5 damage" per card and add five of those to your deck. A rapier might have for of those "5 damage" cards but have a 5th card that does 4 or 8 if it's the first attack in your turn.
    
- Tools are used to generate value during an adventure. They might also be used as a weapon. A hatchet might have cards that say "Collect 2 lumber or do 3 damage". Similarly, a battle axe might have cards that say "Do 8 damage or collect 2 lumber".
    
- Armor provides protection to the character and other abilities. There will be tension between armor's protection and value generating abilities. An adventurer's leather jerkin might give you two block every turn. A Berserker's loincloth might not have any protection, but instead adds +1 damage and +1 wood to all of your axe cards.
    
- Other misc items may be equip-able too. Maybe you can use both your hands to haul a boulder, creating a disadvantage but providing a reward when the player drops the boulder off at the end of their adventure. Or maybe you can bring a canoe that increases the range you can travel from the fortification but you might not have as many tools, weapons, etc. 
    

- Deck
    

- Deck is automatically constructed by shuffling all the cards added earlier in the day into one pile.
    
- The player will be rewarded for being as efficient as possible when playing their cards. Adventures will not be difficult to complete most of the time. At least early. But the more efficient the player is with using their cards to navigate the adventure, the fewer resources they have to spend to recover and more resources they have to invest.
    

- Cards
    

- Cards should mechanically represent the character, item, etc that put the card in their deck. Once the player has progressed enough in the game to make meaningful choices in their party loadout, some synergy between groups of cards will become apparent. 
    
- Playing cards probably plays out like slay the spire. This needs some more thought and experimentation. 
    

- Post Adventure phase
    

- Player is rewarded if quest was completed.
    
- Player spends resources on healing/repairs. 
    
- Player can purchase items.
    
- Player can buy services to upgrade fortification. 
    

- Fortification
    

- The fortification gets upgraded throughout the course of the game. 
    

- Different kinds of shop keepers will take up residence selling semi-random goods and services. 
    
- The fortification itself is part of the party when attacked. Player will get to use cards defined by the Fortification and its upgrades in addition to their own. 
    

- Infrastructure can also be invested in
    

- Roads can be built between two nodes on the map. This effectively increases the distance the player can choose on certain parts of the map. This does a few things:
    

- Creates a way to add choices to the map over time, so the player isn’t overwhelmed with choices
    
- Is a progress check, ensuring the player has accumulated enough resources to begin adventuring in harder territory
    
- Optional money sink to get one time or situational range increasing items or companions. Canoe, horses, cart, etc