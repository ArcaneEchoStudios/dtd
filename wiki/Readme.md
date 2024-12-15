This will be the entry point for the wiki, once we know whatever we're going to be building/designing to. 

## Core Functionality
- Main Menu
- Save Files
- Matchmaking (if necessary)
- Sound
- Animations

## Minigames Or Many Games?
Discussing in person with @Robin, I realized we had very different ideas of how we were stringing our game together. Robin was thinking about many (little) games you could switch between (UFO50). My plan was to work on a ton of little mechanics/games that don't necessarily make sense to string together. I think these ideas aren't exclusive, because we should be able to implement either style of many/mini games with the framework.

## What do I want to work on?
I want to build all of the game that isn't actually the parts getting played. I want to delegate the fun/mechanics to you guys in touch more with games/industry. 

- New/Load/Main Menu screen
- Create new game
	- Create 4 'players' to sit around the table
	- Allow the user to roll up a starting character for each player
	- Launch the 'Table Scene'
- Load game
	- From a save file, proceed to 'Table Scene'
- Table Scene
	- Show the 4 players around a table with the DM at the head
	- Options to launch each minigame
		- This is where I want you guys to have many options to choose from
		- Some options here will be static, like [[Recruiter]], [[Camp]] or [[Inventory Management]] game, while others should be based on where they are at in whatever story or part of the adventure they are on like [[Combat]] [[Prison Break]] or [[Story Scenes]]
	- This should also be whatever sort of story building algorithm we have to tie the scenes together (ie, if you are on a dungeon quest, we know at some point we have to finish the dungeon quest before we get to go to the city or something)
## What ties the game together
In SDV, the game is tied together through stamina/hp, inventory and time. STS uses the deck, gold, hp. Every activity takes/provides through this mechanism, or it's not part of the larger game. For the sake of communication, I'm going to call this the Game Contract

Game Contract is what is modified between minigames. Any data that is not part of the contract is part of the minigame instead. Let's take the SDV museum. It's meaningful part of the interaction is +/- inventory. All the positioning of items, what reward levels, what has been donated is minigame data that is stored outside of the accessible game state. Same thing for the matching game in slay the spire. 

This encourages us to use the Game Contract where possible (all the structure and save mechanics are standard) but gives us the flexibility of storing data in different ways

## What would our Game Contract be?
- List of PCs
	- Stamina (#) (current)
	- Skill (#)
	- Stats
		- Strength (#)
		- Smarts (#)
		- Social (#)
		- Stamina (#) (max)
		- Speed (#)
	- Stuff (list of strings, `greatsword` or `magic missle`)
	- Status (list of string, tags like `poisoned`, `cursed`, `sleeping`)
	- Style (string `mage`, `warrior`)
- Silver
- Day (in order to keep track of how long something has run)

What's stored on the contract is nothing more than a string. If your minigame has behavior for the sword, you are responsible for the sword