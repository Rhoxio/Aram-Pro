# Aram-Pro

###### Aram Pro is a website centered around providing metagame data for the All-Random All-Mid (ARAM) gamemode on League of Legends. The basic premise of this app is to provide a central hub for fans of the ARAM game mode to come and share information and use the tools provided to improve their gameplay.

Right now, the site is in early development phases and is primarily an excersise in consuming and utiling the Riot Games API. once the main features are fleshed out, there will be a public release in hopes of generating some substantial user data to help bolster the accuracy and popularity of the website.

This is a Rails app with the front-end being built on Foundation and React. If you would like to contribute, send an email to [Kevin (Rhoxio)](mailto:rhoxiodbc@gmail.com) to get a copy of the required secret development files. Currently, some key functionality still needs to be built. Once you get access, check out the issues and start building!

## Currently Working On

### The distinction between games that are 'current' and 'finished'

 - The front-end needs to be able to distinguish between a game that is currently happening versus a saved game so that the UI templates can distiguish between the two. 
 - It also needs to be in place due to the fact that games that were previously in the 'current game' state will be queried against the Riot API using Sidekiq or some task runner to get item and outcome data for those matches.

This can be accomplished by: 
 - Making sure that games saved through the 'get current game' route are affixed with a new attribute called game_state. This is going to live directly on the model as an attribute for easy querying.
 - A query and action will need to be created then then fed through the task runner at a set interval to poll the Riot API for new game data. Since all of the data from both endpoints end up giving back simlar data, so it should really only be a matter of assigning the new items to the old model in all reality.
