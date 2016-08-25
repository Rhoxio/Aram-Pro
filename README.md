# Aram-Pro

###### Aram Pro is a website centered around providing metagame data for the All-Random All-Mid (ARAM) gamemode on League of Legends. The basic premise of this app is to provide a central hub for fans of the ARAM game mode to come and share information and use the tools provided to improve their gameplay.

Right now, the site is in early development phases and is primarily an excersise in consuming and utiling the Riot Games API. once the main features are fleshed out, there will be a public release in hopes of generating some substantial user data to help bolster the accuracy and popularity of the website.

This is a Rails app with the front-end being built on Foundation and React. If you would like to contribute, send an email to [Kevin (Rhoxio)](mailto:rhoxiodbc@gmail.com) to get a copy of the required secret development files. Currently, some key functionality still needs to be built. Once you get access, check out the issues and start building!

## Currently Working On

### Setting Up Analytics and Suggestions for Champion Matchups (ARAM Buster Backend Dependencies)

There are some clear-cut goals that will need to be accomlished before ARAM Buster (working title) is fully ready to start accepting requests for simple match analytics. The goal of the feature is to provide users with a utility that helps them make better decisions baed upon their matchup. General weaknesses, like sustain being strong against poke teams but weak against initiation, will be taken in to account.

##### I Don't Have Reliable and Robust Analytics Data (Yet), So...
In order to get initial values that are somewhat accurate, (as I have no meaningful data at the moment outside of wgat will be scraped) I am going to scrape a few different websites and run analytics against them to give the Championbase model more robust data on itself to work with. **(Done)**

##### Match Averages and Other Analytics
I have an attribute set up on the Match model that shows the averages (at the time the match was created and saved) that takes the averages on each champion present in the game's winrates and overall scores and saves it to the Match. This is going to be present on the front-end itself. This also makes it easier for me to run match analytics and give an average spread for similar games _(once that gets implemented)_. **(Done)**

##### Next Up: Item Suggestions
I have a system that scrapes in order to acquire items that are most popularly built, but I need to set up a system that reads tags (or highest offensive/defensive) stat averages and suggests alternative build paths depending on how the game begins to unfold. 

_For post-game analytics, this will mean very little aside from checking if the suggestions were built and how they potentially affected outcomes._

Aram Buster is focused around giving you a realistic view of your chances to win against the other team and increase your chances of winning by providing you with item and "optimal" playstyle information. This is all currently based on tags and I have a utility that calculates tag frequency within a game already built, but it needs to be present on the match model itself. (Semantically, this will keep my controllers and services thin so all I have to do is serve data straight up to the front. Plus, why wouldn't I want to save this on the database for future use?)

##### Persisting the Analytics

I am planning on caching a lot of the data itself on Redis and doing perodic dumps to Postgresql on the same database as everything else is living using Sidekiq. 

#### Analyzing Initial State of the Game

