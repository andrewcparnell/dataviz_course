# Some revision on Rstudio and dplyr
# A quick reminder of the panels in Rstudio
# General workflow: reminder of how to use scripts
# Projects vs setwd
# Code styles including Styler
# Plots vs Viewer vs Presentation
# Starting code with rm(list = ls()) vs CMD/CTRL-Shift-0
# Code sections and collapsing

# Load in the tidyverse as will be using dplyr, tidyr and others
library(tidyverse)

# Use the penguins data
library(palmerpenguins)

# glimpse and Pipes
print(penguins) # It's a tibble
glimpse(penguins)
head(penguins)
tail(penguins)
View(penguins)

# Pip instead for easier reading (CMD/CTRL-Shift-M)
penguins %>% glimpse()

# Arrange
penguins %>% arrange(bill_length_mm)
penguins %>% arrange(desc(flipper_length_mm))

# Selecting and filtering -------------------------------------------------

# Filtering selects rows:
penguins %>%
  filter(sex == "male") # Use ==, !=, <, >, etc

# Multiple criteria
penguins %>%
  filter(sex == "male", species == "Adelie")

# Compare with
penguins %>%
  filter(sex == "male" | species == "Adelie") # Or instead of and

# Filter numerically
penguins %>%
  filter(bill_length_mm <= 40)

# Quick way to remove NA values
penguins %>%
  na.omit()

# Select chooses columns
penguins %>%
  select(species) %>%
  glimpse()

# Can select multiple columns by comma or :
penguins %>%
  select(bill_length_mm:flipper_length_mm)

# Works in negation
penguins %>%
  select(-species) %>%
  glimpse()

# Works with string matching functions
penguins %>%
  select(starts_with("flipper"))
# Though note this doesn't work for filter - need to use e.g. stringr

# Contains
penguins %>% select(contains("body"))

# Select all the numeric columns
penguins %>% select_if(is.numeric)

# Add multiple pipes together
penguins %>%
  filter(bill_length_mm <= 40) %>%
  select(species) %>%
  table()


# Mutate and transmute ----------------------------------------------------

# Mutate adds an existing variable onto the tibble
penguins %>% mutate(bill_area = bill_length_mm * bill_depth_mm)

# Create a single code letter for each species
penguins %>% mutate(species_code = substr(species, 1, 1))

# Transmute removes all non-selected variables
penguins %>% transmute(species, sex,
  bill_ratio = bill_depth_mm / bill_length_mm
)


# pivot_longer and pivot_wider --------------------------------------------

# Your best friends when using ggplot2

# pivot_longer stacks chosen variables on top of each other
penguins2 <- penguins %>%
  mutate(row = row_number()) %>% # We need this for later
  pivot_longer(
    cols = c(
      "bill_length_mm", "bill_depth_mm",
      "flipper_length_mm", "body_mass_g"
    ),
    names_to = "measurement",
    values_to = "value"
  )
# Storing this so I can undo it again later

# Can make the call fancier
penguins %>%
  pivot_longer(
    cols = contains("length"),
    names_to = "measurement",
    values_to = "value"
  )

# pivot_wider does the opposite
penguins2 %>%
  pivot_wider(
    names_from = measurement,
    values_from = value
  ) %>%
  select(-row)


# Unite and separate ------------------------------------------------------

# Unite combines two columns together
penguins3 <- penguins %>% unite(col = "species_island", species, island, sep = "_")

# Can undo this with separate
penguins3 %>%
  separate(col = "species_island", into = c("species", "island"), sep = "_")


# Group and summarise -----------------------------------------------------

# Create a mean across species
penguins %>%
  group_by(species) %>%
  summarise(mean_bill_length = mean(bill_length_mm, na.rm = TRUE)) # Remove NAs

# Count the number of penguins of each sex
penguins %>%
  group_by(sex) %>%
  summarise(penguin_count = n())

# Group by multiple variables
penguins %>%
  group_by(species, sex) %>%
  summarise(max_flipper_length = max(flipper_length_mm, na.rm = TRUE))

# Can make the functions more complicated
penguins %>%
  group_by(island) %>%
  summarise(mean_bill_ratio = mean(bill_depth_mm / bill_length_mm, na.rm = TRUE))

# Joining data sets together ----------------------------------------------

# Add an extra data set on to the right hand side
island_info <-
  tibble(
    island = c("Biscoe", "Dream", "Torgersen"),
    mean_temp = c(-5, -4, 1)
  )
penguins %>% left_join(island_info, by = "island")

# Other methods allow for richer joins across multiple linking variables


# Putting it all together -------------------------------------------------

# Example
penguins %>%
  pivot_longer(
    cols = c(
      "bill_length_mm", "bill_depth_mm",
      "flipper_length_mm", "body_mass_g"
    ),
    names_to = "measurement",
    values_to = "value"
  ) %>%
  ggplot(aes(x = measurement, y = value)) +
  geom_boxplot() +
  scale_y_log10() +
  facet_wrap(~species) +
  coord_flip()
