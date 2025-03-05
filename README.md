# Citi Bike Deserts

Find the story here: [https://cj-robinson.github.io/citi-bike-deserts](https://cj-robinson.github.io/citi-bike-deserts/)

Find the HTML here: [https://github.com/cj-robinson/cj-robinson.github.io/blob/main/citi-bike-deserts/index.html](https://github.com/cj-robinson/cj-robinson.github.io/blob/main/citi-bike-deserts/index.html)

### Overview/Findings

I analyzed Citi Bike station availability throughout the fall of 2024 using a scraper that attempted to run every 10 minutes. As a newly minted Citi Bike member myself, I have often found myself attmepting to dock a bike in a neighborhood where others were also circling waiting for dock space to open up. I found that these deserts occur throughout the city and often have a time-based dimensions in morning and evening rushes. 

### Goals

The focus of this project was on responsive design and utilziing Illustrator/ai2html. I wanted to ensure mobile design was taken into account by utlizing vertical space while also having some fun with mapping in ggplot. 

This was an assignment for our Data Studio class at Columbia Journalism School's Data Journalism program, intended to think about how to create end-to-end data stories about topics of our choosing on deadline.

### Data Collection and Analysis

The code and deaggregated data for scraping can be found [here](https://github.com/cj-robinson/citi-bike-gbfs). The script was set to run every 10 minutes using GitHub actions, but was often delayed or cancelled due to computing restraints. It was forked from a repo created by the city's Comproller's office, found [here](https://github.com/NYCComptroller/citi-bike-gbfs). 

I did exploratory data analysis in R and created the basic maps/bar charts in ggplot (see the **analysis** folder). The comptroller's report had a script that joined all the granular availability scrapes into one file that was then joined on a geojson to match to station locations. For each location, I grouped by weekday and hour and counted the amount of scrapes that showed that bike docks were either full or empty, giving an 'availability rate.' 

To determine reliability, I based the 'good,' 'moderate' and 'bad' categories on 80% being similar to one out of five week days being unavailable and based on the city-wide average. Moderate was between 80-90, and good was above 90. 

### Learnings

This was my first project utlizing ai2html! It took some getting used to but I really enjoyed manipulating annoations/chart types for differing devices without having to change any CSS/JS. I'm excited to use something like Svelte to manage these large chunks of code rather than using a single HTML file though. 

I also found the drawbacks/benefits of choosing which points to switch from R to AI in terms of coloring, cropping and exporting. Especially when trying to iterate quickly, it was nice to have most of the aesthetics programmed in R to ensure that I didn't have to repeat changes in AI.s

To expand on this, I'd love to make this into a scrollytelling piece that guides the reader more immersively through the large city-wide maps at the end and shows more than just three time periods! I'd also love to expand on the comptroller's report that lower-income neighborhoods experienced more service disruptions. 

