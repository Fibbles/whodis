# Who Dis

![Example screenshots are shown with Prat installd which provides additional chat formatting](https://user-images.githubusercontent.com/3208355/188332894-694853ab-ed87-46a8-a1d3-8e5006da6505.png)

## What is it?

A small World of Warcraft addon to display notes besides character names in chat and tooltips.
It will pull information from the guild notes by default but these can be overridden with custom notes.
The main purpose of this addon is to display main character names alongside alts, however
you can use it to set any note you like against a player, in any guild, on any server.


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


`/whodis set CharName note`
- set a custom note
- if the player is a guildie this will override the default guild note

`/whodis hide CharName`
- hide the note for the specified character

`/whodis default CharName`
- removes any custom note and displays the default guild note (if there is one)
 

`/whodis rank-filter RankName`
- set a filter to only show notes for guildies with this rank (off by default)
- if your guild roster is well organised you may only want to display notes against players with rank 'alt'
- leave RankName blank to disable this filter and show notes for all guildies


`/whodis colour-names bool`
- if the addon can recognise a note as a guild member's name it will colour the note based on their class
- true or false

`/whodis colour-brackets bool`
- colour brackets grey or leave them the same colour as the channel's text
- true or false

`/whodis hide-greeting bool`
- hides addon messages from the chat window on load
- true or false


`/whodis help`
- prints a full list of commands and options to the chat window
