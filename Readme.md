# Our game

It all starts with /project.godot. From there, we can see that it loads the introduction 
scene, game.tscn. There are other settings in that file that relate to the game settings. 
This is the text version of the godot's Project Settings

The Scenes work as templates and entry points into the behavior. Scenes are a list of 
nodes that can be structured and nested. A node can have data, scripts and behavior. 

At the time of writing, my scenes are very flat. Eventually, there would be a tree of 
reusable components You can see all of the nodes in a scene in vscode's plugin or in 
the godot editor.

All of the scripts are in /src. I don't have a good understanding of how they should be
kept in sync with the scenes they might be paired with. I'm not seeing any reason for 
a scene that doesn't have any scripts, so this feels weird to keep them far apart. 

Everything in /combat is a prototype and is messy and icky.

Our wiki is hosted [here](/wiki)