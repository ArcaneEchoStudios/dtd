# Introduction

Delve the Dungeon is a platform for... something that might one day be a video
game. Today, it is a collection of toys and ideas that we're shaping into that.

## Tools:
- [Godot](https://godotengine.org/) for... well, everything really.
- [Aseprite](https://www.aseprite.org/) for sprite editing
- [VC Code](https://code.visualstudio.com/) and [godot plugins](https://docs.godotengine.org/en/stable/contributing/development/configuring_an_ide/visual_studio_code.html)

## Structure
The main game is launched from the project.godot. That is configured to launch
the game scene. The game scene (.tscn), and the associate script (.gd) controls
the highest level game state, such as window size, what scene is currently on,
and maybe more as we learn. 

The way we think about a game is a series of scenes that can be linked through
a [Game Contract](https://github.com/kalebpomeroy/dtd/wiki#what-would-our-game-contract-be).
Each time a scene loads, it should game the current context from the Game 
Contract. Adhering to this allows us to seamlessly tie scenes together while 
maintaining flexibility to do anything you want inside of a single minigame.

The default scene that game.tscn loads is the main menu. This is a mini-game
launcher that allows you to open one of the existing minigames. Eventually
options for loading a save file, game play settings and the like will be
launched from here. 

Right now, all logic exists in the minigames. There's no sort of a shared
folder for reusing components. Buttons, tranistions, animations, movement...
All thing we'll likely want to be accessible across scenes.

## Contributing
For an explanation of our git expectations: 
[Git Process](https://github.com/kalebpomeroy/dtd/wiki/Git-Hygiene)

### VS Code configurations
If you're working in vs_code, there's a little extra setup work required. 
In the project root there is a .vscode.example directory that needs to be 
moved into .vscode and modified for your local environment.

### Debugging
#TODO: I know actually know how to use the debugger and stuff

### Testing
#TODO: We should have some testing guidelines

### PR Process
#TODO: We should have a process

### linting, precommit hooks and stuff
#TODO: Yes please

## Reporting Issues
Create a GH Issue for now

