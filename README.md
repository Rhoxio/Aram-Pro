# Aram-Pro

###### Aram Pro is a website centered around providing metagame data for the All-Random All-Mid (ARAM) gamemode on League of Legends. The basic premise of this app is to provide a central hub for fans of the ARAM game mode to come and share information and use the tools provided to improve their gameplay.

Right now, the site is in early development phases and is primarily an excersise in consuming and utiling the Riot Games API. once the main features are fleshed out, there will be a public release in hopes of generating some substantial user data to help bolster the accuracy and popularity of the website.

This is a Rails app with the front-end being built on Foundation and React. If you would like to contribute, send an email to [Kevin (Rhoxio)](mailto:rhoxiodbc@gmail.com) to get a copy of the required secret development files. Currently, some key functionality still needs to be built. Once you get access, check out the issues and start building!

## Currently Working On

### Setting Up Analytics and Suggestions for Champion Matchups

There are some clear-cut goals that will need to be accomlished before ARAM Buster (working title) is fully ready to start accepting requests for simple match analytics. The goal of the feature is to provide users with a utility that helps them make better decisions baed upon their matchup versus the other team. General weaknesses, like sustain being strong against poke teams but weak against strong engage, will be taken in to account.

This functionality will be accomplished by taking a pre-calculated champion winrate percentage and running an arbitrary 'score' (based on matchup viability; namely on usefulness to their own team and strength against the enemies' team) and giving back a generalized build path for the player's current champion.

For example, let's say you are playing Alistar versus a heavy poke team who primarily uses magic damage. Stats like magic resist, health regen, mana, and tenacity are going to be important things to have as a tank. The utility should give back suggestions like Spirit Visage or Merc treads. It may even suggest something like Frozen Heart if the utility sees that Alistar is the only source of health sustain (any may suggest leveling his E first) or is the only tank on the team. It may also suggest it if there is a source of physical damage on their team.

* Not quite done. WIll add more explanation. *

#### Analyzing Initial State of the Game

