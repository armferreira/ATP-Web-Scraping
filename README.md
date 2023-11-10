# ATP Web Scraping Script

This script, written in R, is designed to extract data from the official website of the Association of Tennis Professionals (ATP). The resulting dataset includes tournament details, match results, player information, rankings, and various additional variables, making it a valuable resource for tennis analytics and insights.

## Overview

The script is divided into five major tasks, each serving a specific purpose:

### 1. Webscraping Tour Data

The first task focuses on collecting tournament data. The script starts by defining a date range and specified tournament locations. It then installs and loads the required R packages, including `rvest` for HTML extraction and `furrr` for parallel processing. The script extracts tournament data from the ATP website, filtering by specified locations, and stores it in a data frame.

### 2. Webscraping Match Data

In the second task, the script collects match data. It creates an empty data frame to store match details and initializes a unique identifier. The script iterates through tournament URLs, extracts match data, and processes it. It also handles player links, scores, and other match-related information.

### 3. Webscraping Player Data

Task three is focused on scraping player data. The script detects the number of available CPU cores and utilizes parallel processing. It creates a list of unique player IDs from match data and defines a rate limiter. The script then scrapes player data, including wins, losses, titles, age, height, weight, playing style, and more.

### 4. Webscraping Rankings

The fourth task concentrates on extracting rankings data. The script determines the date range and parses HTML to extract ranking data. It retrieves rankings for each player on specific dates, creating a dictionary of rankings by date. For backup purposes, the rank data is saved as a .JSON file.

### 5. Putting Everything Together

The final task combines all the collected data into a single dataset. It matches match data with tournament and player data, calculates various variables, and appends them to the final dataset. The resulting dataset contains a wealth of information, including player rankings, match outcomes, player statistics, and more.

## The Final Dataset

The final dataset is exported into a .csv file. Each row represents a single unique match. The fields/columns are described as follows:

### `round`
- Text describing which round of the tournament the match was played on.

### `player1_id`, `player2_id`
- A unique id for each player composed of 3 elements: first name, last name, and an alphanumeric value.

*Note*: Player 1 and Player 2 represent the two competitors in the match, with Player 1 being the winner and Player 2 the one defeated.

### `score`
- Numbers in a structured format that represent the final match score.

### `tournament`
- The name of the ATP tournament where the match took place.

### `location`
- The city where the tournament took place.

### `total_financial_commitment`
- The overall financial investment committed to the tournament’s prize money.

### `currency`
- The currency used for the financial commitment.

### `surface`
- The type of playing surface in the match tennis court.

### `in_out`
- Indicates whether the match was played indoors or outdoors.

### `p1_rank`, `p2_rank`, `rank_dif`
- The rankings of Player 1 and Player 2, respectively, 1 month before the match. Also, the absolute difference between those rankings.

### `p1_age`, `p2_age`, `age_dif`
- The age of Player 1 and Player 2 at the time of the match. Also, the absolute difference between the two.

### `p1_height`, `p2_height`, `height_dif`
- The height of Player 1 and Player 2. Also, the absolute difference between the two.

### `p1_weight`, `p2_weight`, `weight_dif`
- The weight of Player 1 and Player 2. Also, the absolute difference between the two.

### `p1_hand`, `p2_hand`
- The playing hand for Player 1 and Player 2.

### `p1_backhand`, `p2_backhand`
- The style of backhand for Player 1 and Player 2.

### `p1_nat`, `p2_nat`
- The nationality of Player 1 and Player 2 represented by the country’s code.

### `number_of_sets`
- The number of sets played in the match.
