# Who Dis

![Example screenshots are shown with Prat installd which provides additional chat formatting](https://user-images.githubusercontent.com/3208355/188332894-694853ab-ed87-46a8-a1d3-8e5006da6505.png)

## What is it?

A small World of Warcraft addon to display notes besides character names in chat and tooltips.
It will pull information from the guild notes by default but these can be overridden with custom notes.
The main purpose of this addon is to display your guild's main character names alongside alts.
However, you can use it to set a custom note against any player, in any guild, on any server.


## Limitations

To maintain maximum compatibility with the many chat addons out there, notes are placed into the chat
body, rather than modifying the sender's name. A side effect of this is that you will see two colons if
a character note is displayed, eg:

`[Channel] [CharName]: (Note): message`

Due to the way the WoW API provides guild information, it may take up to 30 seconds from
login for notes to start showing when you use the addon for the first time.

 
## Commands

The most commonly used commands are listed here, however there are more available via the in-game help.

Character names are not case sensitive and are assumed to be on your realm. If you specify the realm then the character name and realm are case sensitive.

`/whodis`
- Opens the GUI

`/whodis help`
- Prints a full list of slash commands and options to the chat window

`/whodis set CharName note`
- Sets a custom note
- If the player is a guildie this will override the default guild note

`/whodis hide CharName`
- Hide the note for the specified character
- Useful if there is a default guild note you don't want to see

`/whodis default CharName`
- Removes any custom note and displays the default guild note (if there is one)



