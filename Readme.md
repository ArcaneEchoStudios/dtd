# Our game

It all starts with /project.godot. From there, we can see that it loads the introduction
scene, game.tscn. There are other settings in that file that relate to the game settings.
This is the text version of the godot's Project Settings

All of the logic right now exists in sub folders related to a single minigame. Eventually
we'll want to have some sort of shared folder for things that make sense to share; buttons
transitions, movement scripts. But I don't know what the right way to do that yet.

All of the scripts are kept in the same folder. Conventional wisdom suggests having a src
directory and a scenes directory and keep the code and src separate. That seems foolish.

The game.tscn (scene) and associated game.gd (script) is the real entry point for the game.
scenes/main-menu controls... you guessed it the main menu :p
Everything in /scenes/clock-combat is a prototype and is messy and icky.

Our wiki is hosted [here](/wiki)