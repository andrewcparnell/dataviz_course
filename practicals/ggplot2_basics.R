# A broad overview of ggplot2

# Lots of resources that go with this in case you want to find out more:
# Obvious one is the ggplot2 book by Wickham - partly free here http://ggplot2.org/book/
# The ggplot2 documentation at: http://ggplot2.org
# The introduction guide by Matloff: http://heather.cs.ucdavis.edu/~matloff/GGPlot2/GGPlot2Intro.pdf
# Stack overflow ggplot2: http://stackoverflow.com/questions/tagged/ggplot2
# Rstudio cheat sheet: https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf
# R-bloggers: https://www.r-bloggers.com/search/ggplot2
# ggplot2 extensions: http://www.ggplot2-exts.org/gallery/

# Packages required for this script
library(tidyverse)
library(quantreg)
library(viridis)
library(latex2exp)
library(hexbin)
library(palmerpenguins)

# ggplot2 - the basics ----------------------------------------------------

# The key to ggplot is to have a data frame
# We will use one that comes with the package on fuel economy
penguins %>% glimpse()

# let's get rid of the missing values to make this less warning-y
penguins <- penguins %>% na.omit()

# Here is some code to produce a cool plot in ggplot2.
# Just run it - don't worry about what it does yet
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm, colour = species)) +
  geom_point() +
  xlab("Bill length (mm)") +
  ylab("Flipper_length (mm)") +
  geom_smooth() +
  scale_color_discrete(name = "Species")

# All you need for a ggplot is a data frame, an aesthetic, and a geom
# An aesthetic is just a list of the variables in your plot, and possible colours, groups or fill types
# A geom is just a geometric object that ggplot will create. Without the geom, you won't get anything on the plot
# Different commands in ggplot are separated by + which separates everything out into layers

# Let's start by creating a simple scatter plot of bill_length_mm vs bill_length_mm
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point()
# So geom_point draws a scatter plot

# geom_line by contrast draws lines
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_line()

# Here's the clever thing: we can store the first function call in an object and then add to if if we want to change things
my_plot <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm))
my_plot + geom_point()
my_plot + geom_line()

# Here are some geoms for some common 1D graphs
p <- ggplot(penguins, aes(x = flipper_length_mm))
p + geom_histogram()
p + geom_density()
p + geom_bar()

# Here are some common geoms with 1 discrete and 1 continuous variable
p <- ggplot(penguins, aes(x = species, y = flipper_length_mm))
p + geom_boxplot()
p + geom_violin()

# Customisation -----------------------------------------------------------

# Let's start with a scatter plot
p <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point()

# axis labels and titles - use \n to separate over lines
p + xlab("Engine size") + # CHANGE THIS
  ylab("Highway miles\nper gallon") +
  ggtitle("A scatter plot")

# Colours and shapes - specify in the aesthetic
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm, colour = species)) +
  geom_point()
# Alternatively you can specify in the geom
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point(aes(colour = species))
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point(aes(shape = species))
# Note that the legend is added automatically

# Changing axis styles
# Expand the axis - short version
p + xlim(c(40, 50)) + ylim(c(180, 220))
# Expand the axis, longer version
p + scale_x_continuous(limits = c(40, 50))

# Change the number of labels
p + scale_y_continuous(breaks = seq(170, 235, by = 5))

# Change the type of labels
p + scale_x_continuous(
  breaks = seq(30, 60, by = 5),
  labels = letters[1:7]
)

# Changing coordinate structures - amazingly easy
# Reverse an axis
p + scale_x_reverse()
# Change to a log scale
p + scale_x_log10()
# Use + scale_y_continuous(trans = "log") for natural log scale
# Even change the whole coordinate system
p + coord_flip()
p + coord_polar()

# Facets
# Break up into multiple panels using a formula
p + facet_wrap(~ species) # 3 columns, 1 row
p + facet_wrap(species ~ year) # 3 columns, 3 rows
p + facet_grid(island ~ species)
# NB facet wrap wraps things round in multiple columns/rows, facet_grid forces things onto single rows/columns (perhaps slightly different to what I said in the lecture)

# You can even do some fancy things with keeping the axes constant or not
p + facet_wrap(~species, scales = "free")
p + facet_wrap(~species, scales = "free_x") # x is free, but not y
# See ?facet for many more details

# Saving ggplots - gets the file type from the extension
# ggsave(p, file = 'my_plot.pdf', width = 12, height = 8)

## EXERCISE 1

# I want to create a boxplot of flipper_length_mm for each island Fill in the blanks [A] and [B]:
# ggplot(penguins, aes([A], flipper_length_mm)) + geom_[B]()

# I want to create a histogram of bill_length_mm by island. Fill in the blanks [A] and [B]:
# ggplot(penguins, aes([A] = bill_length_mm)) +
#   geom_histogram() +
#   facet_wrap( ~ [B])

# Advanced customisation --------------------------------------------------

# Adding statistics

# Most commonly used is geom_smooth
p <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point()
p + geom_smooth() # Default is loess for smaller data sets
# Also by default includes a 95% confidence interval
p + geom_smooth(method = "lm") # Other options: glm, gam, ...
p + geom_smooth(method = "gam")
# The smooth will automatically split by groups
p <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm, colour = species)) +
  geom_point()
p + geom_smooth(method = 'lm')

# Other useful stats:
p + geom_quantile() # Quantile regression
# Some geoms we've already met have equivalent stat versions, e.g. geom_bar = stat_bin

# Add a function to a density plot
p <- ggplot(penguins, aes(x = flipper_length_mm)) +
  geom_density()
p + stat_function(fun = dnorm, args = list(mean = 200, sd = 10), colour = "red")

# Jittering
# Avoid over plotting, compare
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point()
# with
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point(position = "jitter", alpha = 0.5)
# with
ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  # geom_point() +
  geom_jitter(width = 0.2, height = 0.5)

# Add a line with geom_abline
p <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm)) +
  geom_point()
p + geom_abline(intercept = 140, slope = 1, col = "red")
p + geom_vline(xintercept = 40, col = "blue")
p + geom_hline(yintercept = 200, col = "green")

# Themes
# A beautiful aspect of ggplot2 is the ability to completely change the look of the graph with just a single command. We do this via specifying different themes
p + theme_bw() # My favourite
p + theme_minimal()
p + theme_dark()
p + theme_light() # Slightly darker gridlines to theme_bw
p + theme_void() # Almost empty
# There is also a ggtheme package with way more - see https://cran.r-project.org/web/packages/ggthemes/vignettes/ggthemes.html

# Fiddling with legends
# As soon as you start adding groups ggplot will automatically add a legend
p <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm, colour = species)) +
  geom_point()
p
# You can use the theme command to do all kinds of edits to the plot; more on that below, but here we'll focus on playing with the legend
# Move is to the top
p + theme(legend.position = "top")
# Remove the legend
p + theme(legend.position = "None")
# Put it somewhere deliberate
p + theme(legend.position = c(0.5, 0.8)) # Note these are relative to the plot
# Make it bigger
p + theme(legend.key.size = unit(2.5, "cm"))
# Remove the legend title
p + theme(legend.title = element_blank())
# Changing the legend title is fiddlier as it involves playing with the structure of the colours in the elegend
p + scale_colour_brewer(name = "A new title") # Note the change in colours
# Change the legend font
p + theme(legend.title = element_text(family = "Courier", face = "italic" ))
# Note that above we're using element_text and element_blank. These are ggplot's special functions for setting text types (font, size, colour, etc). element_blank removes everything

# Advanced colour scales
# scale_colour_brewer will give your data a nice colour scheme
p + scale_colour_brewer()
p + scale_colour_brewer(palette = "Greens")
p + scale_colour_brewer(palette = "Spectral")
# A cool list of the different palettes is available here: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/

# ggplot will quite happily work with continuous legends but you need to use scale_colour_gradientn instead
p <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm, colour = body_mass_g)) +
  geom_point()
p
p + scale_colour_gradientn(colours = heat.colors(4))

# A far cooler palette comes from the viridis package
library(viridis)
# See https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
p + scale_color_viridis()
p + scale_color_viridis(option = "A")

# Adding maths
# Another useful package is latex2exp which works with both base graphics and ggplot2 to add in proper equations using latex style commands
library(latex2exp)
p + xlab(TeX("$\\sin(x + 3y)$")) + ggtitle(TeX("$p(B|A) \\propto p(A|B) \\times p(B)$"))
# This is Latex code (something we'll meet in a bit more detail later in the course) where $ indicates the start/end of an equation and \\ is used to indicate a special equation structure

## EXERCISE 2

# Play with some colour gradients. Start with
p <- ggplot(penguins, aes(x = bill_length_mm, y = flipper_length_mm, colour = flipper_length_mm)) +
  geom_point()
# I want to create a colour gradient that goes from white (low flipper_length_mm) to blue to black (high flipper_length_mm)
# What should go in the blanks?
# p + scale_colour_gradientn(colours = [X])

# Write a ggplot function which uses the label aesthetic and the geom_text geom to add the drive type (species) to the plot.

# Even more advanced customisation ----------------------------------------

# Common problems with ggplot2 - or - things I always get wrong


# Example 1 ---------------------------------------------------------------

# EXAMPLES NEED TO BE RE-WRITTEN IN TIDYVERSE STYLE

# A time series plot with error bars

# Read in the data, remove first row, identify variable types, and missing values
glob_temp <- read.csv("https://data.giss.nasa.gov/gistemp/tabledata_v3/GLB.Ts+dSST.csv",
  skip = 1,
  colClasses = "numeric",
  na.strings = "***"
)
# Add in the yearly standard deviation
glob_temp$J.D.sd <- apply(glob_temp[, 2:13], 1, "sd", na.rm = TRUE)
# Add in lower and upper CIs
glob_temp$lower <- with(glob_temp, J.D - 2 * J.D.sd)
glob_temp$upper <- with(glob_temp, J.D + 2 * J.D.sd)
# Create a new data frame with a smooth
smooth <- data.frame(with(glob_temp, ksmooth(Year, J.D, bandwidth = 15)))

# Missing one obs - full 2016 data
ggplot(glob_temp, aes(x = Year, y = J.D, colour = J.D)) +
  geom_line(linewidth = 1) + # Add thicker line
  theme_bw() + # Nicer theme
  scale_x_continuous(breaks = seq(1880, 2020, by = 10)) + # Better x-axis every 10 years
  scale_color_viridis(option = "A") + # Viridis colour palette
  ylab(TeX("Temperature\nanomalyin $^$degree$C$")) + # Proper axis label with
  ggtitle(TeX("NASA global surface temperature data (mean $\\pm$ 2 standard deviations)")) +
  theme(axis.title.y = element_text(angle = 0, vjust = 1, hjust = 0)) + # Put y-axis label correctly
  theme(legend.position = "none") + # Remove legend
  geom_errorbar(aes(ymin = lower, ymax = upper)) + # Add in vertical error bars
  geom_line(data = smooth, aes(x = x, y = y, colour = y)) # Add in new data frame with smooth

# Example 2 ---------------------------------------------------------------

# A nice map - adjusted from http://docs.ggplot2.org/current/geom_map.html
library(maps)
crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
crimesm <- reshape2::melt(crimes, id = 1)
crimesm$variable2 <- factor(crimesm$variable, labels = c("Murder arrests (per 100,000 people)", "Assault arrests (per 100,000)", "Percent urban population", "Rape arrests (per 100,000)"))

states_map <- map_data("state")

ggplot(crimesm, aes(map_id = state)) +
  geom_map(aes(fill = value), map = states_map) +
  theme_bw() +
  scale_fill_viridis(option = "B") +
  ylab("Latitidue") +
  xlab("Longitude") +
  expand_limits(x = states_map$long, y = states_map$lat) +
  facet_wrap(~variable2)

# If you want a different legend for each one see the gridExtra package

## EXERCISE 3

# Grand challenge. Using the global temperature data can you re-create the plot called 'Monthly Mean Global Surface Temperature' on this page exactly: https://data.giss.nasa.gov/gistemp/graphs/? The data for the plot are at: http://data.giss.nasa.gov/gistemp/graphs/graph_data/Monthly_Mean_Global_Surface_Temperature/graph.csv
# Hints:
# 1) Watch the year range - it's not a plot of the full data
# 2) You'll need to melt the data to get the two lines correctly
# 3) Attached is my version. See if you can do better
# 4) Post your code in the box, including the command to load the data in from the web (i.e. the first line should contain read.csv with a URL). A decent attempt gets 6/10. Matching mine exactly gets 9/10. Improving on mine get 10/10. Include comments to say what you've done
