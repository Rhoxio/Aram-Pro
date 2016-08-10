# Aram-Pro

###### Aram Pro is a website centered around providing metagame data for the All-Random All-Mid (ARAM) gamemode on League of Legends. The basic premise of this app is to provide a central hub for fans of the ARAM game mode to come and share information and use the tools provided to improve their gameplay.

Right now, the site is in early development phases and is primarily an excersise in consuming and utiling the Riot Games API. once the main features are fleshed out, there will be a public release in hopes of generating some substantial user data to help bolster the accuracy and popularity of the website.

This is a Rails app with the front-end being built on Foundation and React. If you would like to contribute, send an email to [Kevin (Rhoxio)](mailto:rhoxiodbc@gmail.com) to get a copy of the required secret development files. Currently, some key functionality still needs to be built. Once you get access, check out the issues and start building!

## Currently Working On

### Setting Up Analytics and Suggestions for Champion Matchups

There are some clear-cut goals that will need to be accomlished before ARAM Buster (working title) is fully ready to start accepting requests for simple match analytics. The goal of the feature is to provide users with a utility that helps them make better decisions baed upon their matchup versus the other team. General weaknesses, like sustain being strong against poke teams but weak against strong engage, will be taken in to account.

This functionality will be accomplished by taking a pre-calculated champion winrate percentage and running an arbitrary 'score' (based on matchup viability; namely on usefulness to their own team and strength against the enemies' team) and giving back a generalized build path for the player's current champion.

For example, let's say you are playing Alistar versus a heavy poke team who primarily uses magic damage. Stats like magic resist, health regen, mana, and tenacity are going to be important things to have as a tank. The utility should give back suggestions like Spirit Visage or Merc treads. It may even suggest something like Frozen Heart if the utility sees that Alistar is the only source of health sustain (any may suggest leveling his E first) or is the only tank on the team if there is a source of physical damage on their team.

##### I Don't Have Real Analytics Data, So...
In order to get initial values that are somewhat accurate, (as I have no meaningful data at the moment outside of what I have collected personally and what has been scraped) I am going to scrape a few different websites and run analytics against them to give the Championbase model more robust data on itself to work with. 

I am going to have to come up with a table that basically has counters ad strengths highlighted for all tags in the champ_tags hash in the championbase.rb file. This is going to be self-judgement based until I get enough data to actually run analytics and calculations against the pre-assigned tags. It may come to pass that some of the tags get nuked or end up maintaining precedence over other tags in certain matchups. 

An example of ths would be something like: A team with lots of auto-attacking champions will not be inherently weak against a team with lots of tanks if there is a high dps mage present and some sort of peel or hard CC. If they are all squishy and have no way to peel or CC, then their winrate projection will drop sharply as they have entered a matchup with no real way to counter the other team outside of itemization and personal skill. However, if you end up in a matchup where both teams are very poke heavy, more weight will be given to champions with healing abilities, tanky initiators (not just initiators), and champions with good early games (as pressure early with heavy poke can end up snowbaling games out fo control easily). 

##### Persisting the Analytics

I am planning on caching a lot of the data itself on Redis and doing perodic dumps to Postgresql on the same database as everything else is living using Sidekiq. 

#### Analyzing Initial State of the Game

