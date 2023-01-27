# More examples of the code from classes 4 and 5
# Includes:
# More examples of GGally
# corrplot
# dygraph
# ggfortify


# All of these using tidyverse
library(tidyverse)

# GGally ------------------------------------------------------------------

library(GGally)
library(palmerpenguins)

# Type used in class 4:
ggpairs(penguins %>% na.omit(),
  columns = c("species", "bill_length_mm", "sex"),
  upper = list(continuous = "density"),
  lower = list(continuous = "points")
)

# Can add in more mappings
ggpairs(penguins %>% na.omit(),
  columns = c("species", "bill_length_mm", "sex"),
  upper = list(continuous = "density"),
  lower = list(
    continuous = "smooth",
    combo = "facetdensity",
    mapping = aes(color = island)
  )
)

# Full list of possible panel plots in ggally_* functions


# corrplot ----------------------------------------------------------------

library(corrplot)

cor_mat <- cor(penguins %>% select_if(is.numeric),
  use = "pairwise.complete.obs"
)

# Version used in class 4
corrplot(cor_mat)

# With squares
corrplot(cor_mat, method = "color", order = "alphabet")

# Ellipses
corrplot(cor_mat,
  method = "ellipse",
  order = "FPC", # First principal component
  type = "upper"
)

# Diverging colour palette
corrplot(cor_mat,
  addCoef.col = "black",
  order = "AOE", # Angular order of eigenvectors
  cl.pos = "b", tl.pos = "d",
  col = COL2("PRGn"), diag = FALSE
)


# dygraph -----------------------------------------------------------------

library(dygraphs)

# Load in sea level data
sl_month <- read.csv("data/sea_level_monthly.csv")
glimpse(sl_month)

# dygraph in class
sl_month %>%
  select(Year, GMSL_mm) %>%
  dygraph() %>%
  dyRangeSelector()

# More advanced
sl_month %>%
  transmute(
    Year,
    GMSL = GMSL_mm,
    GMSL_lwr = GMSL_mm - 2 * GMSL_uncertainty_mm,
    GMSL_upr = GMSL_mm + 2 * GMSL_uncertainty_mm,
  ) %>%
  dygraph(main = "Global mean sea level rise") %>%
  dyAxis("x", drawGrid = FALSE) %>%
  dySeries(c("GMSL_lwr", "GMSL", "GMSL_upr"),
    label = "GMSL"
  ) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(3, "Set1"))

# Now with highlighting
sl_month %>%
  transmute(
    Year,
    GMSL = GMSL_mm,
    GMSL_lwr = GMSL_mm - 2 * GMSL_uncertainty_mm,
    GMSL_upr = GMSL_mm + 2 * GMSL_uncertainty_mm,
  ) %>%
  dygraph(main = "Global mean sea level rise") %>%
  dyAxis("x", drawGrid = FALSE) %>%
  dyHighlight(
    highlightCircleSize = 5,
    highlightSeriesBackgroundAlpha = 0.2,
    hideOnMouseOut = FALSE
  )


# ggfortify ---------------------------------------------------------------

library(ggfortify)
pollen <- read.csv("data/pollen.csv")
pca <- prcomp(pollen[, 3:9], scale. = TRUE)

# Example from class 4
autoplot(pca,
  data = pollen, colour = "MTCO",
  loadings = TRUE, loadings.label = TRUE
)

# For a linear regression
mod_lm <- lm(GDD5 ~ Gramineae,
  data = pollen %>% slice_head(n = 500)
)
summary(mod_lm)

# Quick plot
ggplot(
  pollen %>% slice_head(n = 500),
  aes(x = Gramineae, y = GDD5)
) +
  geom_point() +
  geom_smooth(method = "lm")

# autoplot
autoplot(mod_lm, which = 1:6, ncol = 3, label.size = 3) +
  theme_minimal()

# Autoplot with seasonal data
autoplot(AirPassengers)
autoplot(stl(AirPassengers, s.window = "periodic"),
  ts.colour = "blue"
)

# See also autoplotly!


# ggiraph -----------------------------------------------------------------

library(ggiraph)

# Example in class 5
p <- iris %>%
  mutate(Row.name = 1:n()) %>%
  ggplot(aes(
    x = Sepal.Length, y = Sepal.Width, colour = Species,
    tooltip = Row.name, data_id = Species
  )) +
  geom_point_interactive()
girafe(ggobj = p, width = 10)

# Another example - using penguins
p <- ggplot(
  data = penguins,
  aes(
    x = bill_length_mm,
    y = bill_depth_mm,
    color = species,
    tooltip = island
  )
) +
  geom_point_interactive() +
  ggtitle("Interactive Scatter Plot of Bill Length and Depth")
girafe(ggobj = p, width = 10)

# Slightly richer
p <- ggplot(
  data = penguins,
  aes(
    x = bill_length_mm,
    y = bill_depth_mm,
    tooltip = island,
    data_id = island
  )
) +
  geom_point_interactive(size = 3, hover_nearest = TRUE) +
  ggtitle("Interactive Scatter Plot of Bill Length and Depth")
girafe(ggobj = p, width = 10)

# Interactive bar chart
p <- ggplot(
  data = penguins,
  aes(
    x = species, y = after_stat(count),
    fill = species, tooltip = species
  )
) +
  geom_bar_interactive() +
  ggtitle("Interactive Bar Chart of Penguin Species")
girafe(ggobj = p, width = 10)

# Fancier time series plot
p <- sl_month %>%
  transmute(
    Year,
    GMSL = GMSL_mm,
    GMSL_lwr = GMSL_mm - 2 * GMSL_uncertainty_mm,
    GMSL_upr = GMSL_mm + 2 * GMSL_uncertainty_mm,
  ) %>%
  pivot_longer(-Year,
    names_to = "Type",
    values_to = "GMSL"
  ) %>%
  ggplot(aes(
    x = Year, y = GMSL,
    colour = Type, group = Type
  )) +
  geom_line_interactive(aes(
    tooltip = Type,
    data_id = Type
  )) +
  scale_color_viridis_d()
girafe(
  ggobj = p, width = 10,
  options = list(
    opts_hover_inv(css = "opacity:0.1;"),
    opts_hover(css = "stroke-width:2;")
  )
)

# Cool example from manual - interactive map
crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
# create tooltips and onclick events
states_ <- sprintf(
  "<p>%s</p>",
  as.character(crimes$state)
)
table_ <- paste0(
  "<table><tr><td>UrbanPop</td>",
  sprintf("<td>%.0f</td>", crimes$UrbanPop),
  "</tr><tr>",
  "<td>Assault</td>",
  sprintf("<td>%.0f</td>", crimes$Assault),
  "</tr></table>"
)
onclick <- sprintf(
  "window.open(\"%s%s\")",
  "http://en.wikipedia.org/wiki/",
  as.character(crimes$state)
)
crimes$labs <- paste0(states_, table_)
crimes$onclick <- onclick

states_map <- map_data("state")
gg_map <- ggplot(crimes, aes(map_id = state))
gg_map <- gg_map + geom_map_interactive(
  aes(
    fill = Murder,
    tooltip = labs,
    data_id = state,
    onclick = onclick
  ),
  map = states_map
) +
  expand_limits(x = states_map$long, y = states_map$lat)
girafe(ggobj = gg_map, width = 10)

# Direct labels -----------------------------------------------------------

library(directlabels)
sl_month %>%
  transmute(
    Year,
    GMSL = GMSL_mm,
    GMSL_lwr = GMSL_mm - 2 * GMSL_uncertainty_mm,
    GMSL_upr = GMSL_mm + 2 * GMSL_uncertainty_mm,
  ) %>%
  pivot_longer(-Year,
    names_to = "Type",
    values_to = "GMSL"
  ) %>%
  ggplot(aes(
    x = Year, y = GMSL,
    colour = Type, group = Type
  )) +
  geom_line() +
  geom_dl(aes(label = Type),
    method = list("last.points",
      rot = 30
    )
  ) +
  theme(legend.position = "none") +
  xlim(1880, 2030) +
  ylim(-230, 120)
