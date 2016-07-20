# Aram-Pro

###### Aram Pro is a website centered around providing metagame data for the All-Random All-Mid (ARAM) gamemode on League of Legends. The basic premise of this app is to provide a central hub for fans of the ARAM game mode to come and share information and use the tools provided to improve their gameplay.

Right now, the site is in early development phases and is primarily an excersise in consuming and utiling the Riot Games API. once the main features are fleshed out, there will be a public release in hopes of generating some substantial user data to help bolster the accuracy and popularity of the website.

This is a Rails app with the front-end being built on Foundation and React. If you would like to contribute, send an email to [Kevin (Rhoxio)](mailto:rhoxiodbc@gmail.com) to get a copy of the required secret development files. Currently, some key functionality still needs to be built. Once you get access, check out the issues and start building!

## Currently Working On

### Getting All of the Needed Assets For the UI

Basically, there needs to be functionality built out for grabbing all of the summoner information for each summoner in a match so their names are available. Currently, the code makes as many API calls as they have ARAM matches in their current match history, (so up to 10 if they have played 10 ARAMs, 5 if they have played 5, etc.) but this hits the rate limit very quickly. I am considering only doing live updates for current matches (one api call plus one to get all summoner names) and having the UI update correctly for those. 

For recent matches, it would make more sense to somehow seed the database based upon the createdAt date. The problem would be spinning up a thread asynchronously populate the database as it went baed upon the current rate limit available. I would need to set up a catch for these calls AND normal API calls. (It looks like the Riot API sends a header. https://developer.riotgames.com/docs/rate-limiting.) 


