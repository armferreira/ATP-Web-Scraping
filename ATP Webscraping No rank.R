#################### ATP Web scraping ######################

# Before you start!

# Define year interval here (maximum range between 1974-2023):
start_date <- 1915
end_date <- 2023

# Define wanted locations here:
specified_locations <- c("Australia", "Adelaide", "Albury", "Alica Springs", "Alice Springs", "Barmera", "Bendigo", "Berri", "Blacktown", "Brisbane", "Burnie", "Cairns", "Caloundra", "Canberra", "Darwin", "Frankston", "Geelong", "Gosford", "Happy Valley", "Happy Valley", "Hobart", "Kawana", "Launceston", "Lyneham", "Melbourne", "Mildura", "Mornington", "Perth", "Perth", "Playford", "Port Pirie", "Queensland", "Renmark", "Sydney", "Tasmania", "Toowoomba", "Traralgon", "Victoria", "Wollongong")

# Run the script from start to finish. The CSV files are saved automatically
# on the same folder as this .R program.

# Installing required packages
required_packages <- c("rvest", "furrr", "future", "data.table", "stringr")

for (package in required_packages) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)
  }
}

# Loading required packages
library(rvest) # HTML extraction
library(furrr) # For parallel processing
library(future) # For parallel processing
library(data.table) # Similar to data.frame
library(stringr) # String formatting

# Set file source as working directory 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#################### 1. Web scraping tour_data ######################

# Create an empty data frame to store tournament data
tour_data <- data.frame(
  tournament_id = integer(0),
  name = character(0),
  location = character(0),
  date = as.Date(character(0)),
  surface = character(0),
  prize = character(0),
  currency = character(0),
  link = character(0)
)

# Initialize a unique identifier
tournament_id <- 1

# Loop through years of tour_data
for (year in start_date:end_date) {
  url <- paste0("https://www.atptour.com/en/scores/results-archive?year=", year, "&tournamentType=atpgs")
  
  # Read the HTML content from the web page
  page <- read_html(url)
  
  # Extract all rows from the table
  table_rows <- html_nodes(page, "tr.tourney-result")
  
  # Iterate through the table rows and filter by location
  for (row in table_rows) {
    location <- trimws(html_text(html_node(row, xpath = ".//td[@class='title-content']//span[@class='tourney-location']")))
    # Split the location string into words
    location_words <- unlist(strsplit(location, " |, |-"))
    # Check if any part of the string 'location' match_data with 'specified locations'
    if (any(location_words %in% specified_locations) || location %in% specified_locations) {
      location <- location %>% gsub("/", "-", .) %>% gsub(", Australia", "", .)
      name <- trimws(html_text(html_node(row, xpath = ".//td[@class='title-content']//a[@class='tourney-title']")))
      link <- html_attr(html_node(row, xpath = ".//td[@class='tourney-details']//a[@class='button-border']"), "href")
      surface <- trimws(html_text(html_node(row, xpath = ".//td[@class='tourney-details']/div[@class='info-area']/div[@class='item-details']/span[@class='item-value']")))
      in_out <- page %>% html_node(xpath = '//td[@class="tourney-details"]//div[@class="info-area"]//div[@class="item-details"]/span[@class="item-value"]/preceding-sibling::text()') %>% html_text() %>% trimws()
      numeric_value <- trimws(html_text(html_node(row, xpath = ".//td[@class='tourney-details fin-commit']//span[@class='item-value']")))
      result <- str_match(numeric_value, "([A-Z$£€]+)?([0-9,]+)")
      currency <- result[1, 2]
      currency <- ifelse(currency == "$", "USD", 
                         ifelse(currency == "A$", "AUD", 
                                ifelse(currency == "£", "GBP", currency)))
      prize <- as.integer(gsub(",", "", result[1, 3]))
      date <- row %>% html_node(xpath = './/span[@class="tourney-dates"]') %>% html_text() %>% trimws()
      # Convert 'date' to date type
      date <- gsub("\\.", "-", date) %>% as.Date()
      
      # Append "https://www.atptour.com" to the link
      link <- paste("https://www.atptour.com", link, sep = "")
      tour_data <- rbind(tour_data, data.frame(tournament_id = tournament_id, name = name, location = location, date = date, surface = surface, in_out = in_out, prize = prize, currency = currency, link = link))
      tournament_id <- tournament_id + 1  # Increment the identifier
    }
  }
}

# Print message to console
print ("Task 1 of 4 completed...")

#################### 2. Web scraping match_data ######################

# Create an empty data frame to store match data
match_data <- data.frame(
  match_id = integer(0),
  tournament_id = integer(0),
  round_info = character(0),
  player1_id = character(0),
  player2_id = character(0),
  score = character(0),
  number_of_sets = integer(0)
)

# Initialize a unique identifier
match_id <- 1

# Define the rate limiter (in seconds)
rate_limit <- 0

# Loop through the URLs in the "link" column to get tour_data
for (url in tour_data$link) {
  # Get tournament_id from the corresponding url
  tournament_id <- tour_data$tournament_id[tour_data$link == url]
  
  # Read the HTML content from the URL
  page <- read_html(url)
  
  # Introduce a delay to respect the rate limit
  Sys.sleep(rate_limit)
  
  # Locate and loop through all <thead> elements (rounds) in the table
  round_headers <- page %>% html_nodes(xpath = '//table[@class="day-table"]/thead')
  round_nodes <- page %>% html_nodes(xpath = '//table[@class="day-table"]/tbody')
  
  for (i in 1:length(round_headers)) {
    current_round <- html_text(round_headers[i] %>% html_node("th"))
    
    if (length(current_round) > 0) {
      # Handling NAs and standardizing round name
      if (current_round == "Final") { current_round = "Finals" }
      if (current_round == "Semifinals") { current_round = "Semi-finals" }
      if (current_round == "Olympic Bronze") { current_round = "Semi-finals" }
      if (current_round == "Quarterfinals") { current_round = "Quarter-finals" }
    }
    
    # Loop through the match rows in the current round
    match_rows <- round_nodes[i] %>% html_nodes("tr")
    
    for (row in match_rows) {
      # Use XPath to extract the player links
      player_links <- row %>% html_nodes(".day-table-name a") %>% html_attr("href")
      
      # Extract and format the links
      formatted_player_links <- lapply(player_links, function(link) {
        parts <- strsplit(link, "/")[[1]]
        paste(parts[4], parts[5], sep = "/")
      })
      
      # Assign the formatted links to separate character variables with null value if empty
      player1_id <- ifelse(length(formatted_player_links) >= 1, formatted_player_links[[1]], NA)  # First player's formatted link
      player2_id <- ifelse(length(formatted_player_links) >= 2, formatted_player_links[[2]], NA)  # Second player's formatted link
      
      # Remove dots and quotes from strings to handle special names like (John "Jay" Smith Jr.)
      player1_id <- gsub("\\.", "", player1_id)
      player2_id <- gsub("\\.", "", player2_id)
      player1_id <- gsub('\\"', "", player1_id)
      player2_id <- gsub('\\"', "", player2_id)
      
      # Handle special cases
      player1_id <- gsub("sr:competitor:227358", "w09e", player1_id)
      player2_id <- gsub("sr:competitor:227358", "w09e", player2_id)
      player2_id <- gsub("sr:competitor:754563", "j0d4", player2_id)
      player2_id <- gsub("sr:competitor:675135", "p0kj", player2_id)
      
      # Extract and format the score
      score_raw <- row %>% html_node(xpath = './/td[@class="day-table-score"]/a') %>% html_text()
      score <- str_extract_all(score_raw, "\\S+") %>% unlist() %>% paste(collapse = " ")
      
      # Count the number of numbers in the score
      number_of_sets <- length(unlist(str_extract_all(score, "\\d+")))
      
      # Append the data to the match_data data frame if both player1 and player2 are not NA
      if (!is.na(player1_id) && !is.na(player2_id)) {
        match_data <- rbind(match_data, data.frame(match_id = match_id, tournament_id = tournament_id, round = current_round, player1_id = player1_id, player2_id = player2_id, score = score, number_of_sets = number_of_sets))
        match_id <- match_id + 1  # Increment the identifier
      }
    }
  }
}

print ("Task 2 of 4 completed...")

#################### 3. Web scraping player_data ######################

# Detect the number of available cores and start parallel processing
num_cores <- parallel::detectCores()
plan(multisession, workers = num_cores)

# Create a list of unique player IDs from 'match' data frame
unique_player_ids <- unique(c(match_data$player1_id, match_data$player2_id))
unique_player_ids <- unique_player_ids[!is.na(unique_player_ids)]

# Define the rate limiter (in seconds)
rate_limit <- 0

# Define a function to scrape player data with error handling
scrape_player_data <- function(player_id) {
  url <- paste("https://www.atptour.com/en/players/", player_id, "/overview", sep = "")
  
  tryCatch({
    page <- read_html(url)
   
    name <- page %>% html_nodes(".player-profile-hero-name .first-name, .player-profile-hero-name .last-name") %>% html_text() %>% paste(collapse = " ")
    country <- page %>% html_node(".player-flag-code") %>% html_text()
    country <- ifelse(is.na(country), "RUS", country)
    if(country == ""){country <- NA}
    birthday <- page %>% html_node(".table-birthday") %>% html_text()
    birthday <- gsub("\\s+|\\(|\\)", "", birthday)
    birthday <- gsub("\\.", "-", birthday)
    height <- as.integer(gsub("\\D", "", page %>% html_node(".table-big-label:contains('Height') + .table-big-value .table-height-cm-wrapper") %>% html_text()))
    weight <- as.integer(gsub("\\D", "", page %>% html_node(".table-big-label:contains('Weight') + .table-big-value .table-weight-kg-wrapper") %>% html_text()))
    
    # Extract 'hand' and 'backhand' values
    plays_with <- page %>% html_node(".table-label:contains('Plays') + .table-value") %>% html_text() %>% trimws()
    plays_with <- strsplit(plays_with, ", ")
    hand <- sapply(plays_with, `[`, 1)
    hand <- gsub("-", "", hand)
    backhand <- sapply(plays_with, `[`, 2)
    backhand <- ifelse(backhand == "Unknown Backhand", NA, backhand)
    backhand <- gsub("-", "", backhand)
    
    Sys.sleep(rate_limit)
    
    # Return the player data as a data.table
    return(data.table(player_id = player_id, name = name, birthday = birthday, country = country, height = height, weight = weight, hand = hand, backhand = backhand))
    
  }, error = function(err) {
    cat(paste("Error for player ID:", player_id, " - ", conditionMessage(err), "\n"))
    return(data.table(player_id = player_id, name = NA, birthday = NA, country = NA, height = NA, weight = NA, hand = NA, backhand = NA))
  })
}

# Use furrr to scrape player data in parallel
player_data <- future_map(unique_player_ids, scrape_player_data)

# Close parallel processing when finished
plan(sequential)

# Combine the list of data frames into one data frame
player_data <- do.call(rbind, player_data)

print ("Task 3 of 4 completed...")

#################### 4. Putting everything together ######################

# Initialize final_dataset starting from the 'match_data' data frame
final_dataset <- match_data

# Iterate through each row in the 'match_data' data frame
for (i in 1:nrow(match_data)) {
  match <- match_data[i, ]
  # Find the tournament's date
  date_tournament <- tour_data$date[tour_data$tournament_id == match$tournament_id]
 
  # Calculate age for both player_data at the time of the tournament
  dob_player1 <- as.Date(player_data$birthday[player_data$player_id == match$player1_id])
  player1_age <- as.numeric(round(difftime(date_tournament, dob_player1, units = "days") / 365.25))
  dob_player2 <- as.Date(player_data$birthday[player_data$player_id == match$player2_id])
  player2_age <- as.numeric(round(difftime(date_tournament, dob_player2, units = "days") / 365.25))
  
  # Calculate age difference between player_data (with ifelse to catch NAs)
  age_dif <- ifelse(is.na(player1_age) | is.na(player2_age), NA, player1_age - player2_age)
  
  # Calculate height difference between player_data (with ifelse to catch NAs)
  player1_height <- player_data$height[player_data$player_id == match$player1_id]
  player2_height <- player_data$height[player_data$player_id == match$player2_id]
  height_dif <- ifelse(is.na(player1_height) | is.na(player2_height), NA, player1_height - player2_height)
  
  # Calculate weight difference between player_data (with ifelse to catch NAs)
  player1_weight <- player_data$weight[player_data$player_id == match$player1_id]
  player2_weight <- player_data$weight[player_data$player_id == match$player2_id]
  weight_dif <- ifelse(is.na(player1_weight) | is.na(player2_weight), NA, player1_weight - player2_weight)
  
  # Assign newly calculated fields and fields from other dataframes
  final_dataset[i, "tournament"] <- tour_data$name[tour_data$tournament_id == match$tournament_id]
  final_dataset[i, "location"] <- tour_data$location[tour_data$tournament_id == match$tournament_id]
  final_dataset[i, "date"] <- tour_data$date[tour_data$tournament_id == match$tournament_id]
  final_dataset[i, "prize"] <- tour_data$prize[tour_data$tournament_id == match$tournament_id]
  final_dataset[i, "currency"] <- tour_data$currency[tour_data$tournament_id == match$tournament_id]
  final_dataset[i, "surface"] <- tour_data$surface[tour_data$tournament_id == match$tournament_id]
  final_dataset[i, "in_out"] <- tour_data$in_out[tour_data$tournament_id == match$tournament_id]
  final_dataset[i, "p1_age"] <- ifelse(is.na(player1_age), NA, player1_age)
  final_dataset[i, "p2_age"] <- ifelse(is.na(player2_age), NA, player2_age)
  final_dataset[i, "age_dif"] <- age_dif
  final_dataset[i, "p1_height"] <- ifelse(is.na(player1_height), NA, player1_height)
  final_dataset[i, "p2_height"] <- ifelse(is.na(player2_height), NA, player2_height)
  final_dataset[i, "height_dif"] <- height_dif
  final_dataset[i, "p1_weight"] <- ifelse(is.na(player1_weight), NA, player1_weight)
  final_dataset[i, "p2_weight"] <- ifelse(is.na(player2_weight), NA, player2_weight)
  final_dataset[i, "weight_dif"] <- weight_dif
  final_dataset[i, "p1_hand"] <- ifelse(is.na(player_data$hand[player_data$player_id == match$player1_id]), NA, player_data$hand[player_data$player_id == match$player1_id])
  final_dataset[i, "p2_hand"] <- ifelse(is.na(player_data$hand[player_data$player_id == match$player2_id]), NA, player_data$hand[player_data$player_id == match$player2_id])
  final_dataset[i, "p1_backhand"] <- ifelse(is.na(player_data$backhand[player_data$player_id == match$player1_id]), NA, player_data$backhand[player_data$player_id == match$player1_id])
  final_dataset[i, "p2_backhand"] <- ifelse(is.na(player_data$backhand[player_data$player_id == match$player2_id]), NA, player_data$backhand[player_data$player_id == match$player2_id])
  final_dataset[i, "p1_nat"] <- ifelse(is.na(player_data$country[player_data$player_id == match$player1_id]), NA, player_data$country[player_data$player_id == match$player1_id])
  final_dataset[i, "p2_nat"] <- ifelse(is.na(player_data$country[player_data$player_id == match$player2_id]), NA, player_data$country[player_data$player_id == match$player2_id])
}

# Save dataset as csv file
file_name <- paste("Final_dataset_No_rank_", start_date, "_", end_date, ".csv", sep = '')
write.csv2(final_dataset, file_name, row.names = FALSE)

# Write message to console
print ("Task 4 of 4 completed! :)")