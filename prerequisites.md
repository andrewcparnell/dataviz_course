---
title: "Pre-requisites for Data Visualisation course"
author: "Andrew Parnell"
output: html_document
---

In preparation for the course please install the following, preferably in the below suggested order. Remember you will need your own personal computer with administrator access for the duration of the course and a good internet connection.

As this module will be delivered online please install [Zoom](https://www.zoom.us) and [Slack](https://slack.com) to access the videos and interactive components of the course. All the Zoom links to the meeting will be posted to the Slack `#zoom-links-and-recordings` channel.

### Step 1

Install the following using the corresponding links

-	R: [http://www.r-project.org](http://www.r-project.org)

-	Rstudio (optional but recommended): [https://www.rstudio.com](https://www.rstudio.com)

### Step 2

The `tidyverse` package is the main one we need so install that first:
```{r,eval=FALSE}
install.packages('tidyverse')
```

The rest of the tools we need are optional packages that you will only need if you want to run ALL of the course code:

```{r,eval=FALSE}
install.packages(c(
  "palmerpenguins", "datasauRus", "patchwork", 
  "GGally", "corrplot", "hexbin", "maps", 
  "ggmap", "ggspatial", "leaflet", "dygraphs",
  "ggfortify", "plotly", "ggiraph", "shiny", 
  "gganimate", "animation", "tidymodels", "iml", 
  "DALEX", "ranger", "DALEXtra"
))
```

### Troubleshooting

If you run into any problems please drop me a line on Slack.

