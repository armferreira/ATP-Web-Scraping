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
- Type: Quantitative Nominal
- Classes: Finals, Semi-finals, Round of 16, or...

### `player1_id`, `player2_id`
- A unique id for each player composed of 3 elements: first name, last name, and an alphanumeric value.
- Type: Quantitative Nominal
- Classes: novak-djokovic/d643, andre-agassi/a092, or...

*Note*: For several of our variables, there are mentions of Player 1 and Player 2. They represent the two competitors in the match, with Player 1 being the winner and Player 2 the one defeated.

### `score`
- Numbers in a structured format that represent the final match score.
- Type: Quantitative Nominal
- Examples: A score of ‘62 46 63’ means player1 won the first set by a score of 6-2. A score of ‘31 (DEF)’ means player1 won the match by default (DEF) of his opponent. A 61 20 (RET) means player1 won the match because player2 retired (RET).

### `tournament`
- The name of the ATP tournament where the match took place.
- Type: Quantitative Nominal
- Classes: Australian Open, Adelaide International, or...

### `location`
- The city where the tournament took place.
- Type: Quantitative Nominal
- Classes: Melbourne, Adelaide, or…

### `total_financial_commitment`
- The overall financial investment committed to the tournament’s prize money.
- Type: Qualitative Discrete ❓

### `currency`
- The currency used for the financial commitment.
- Type: Qualitative Nominal
- Classes: USD or AUD.

### `surface`
- The type of playing surface in the match tennis court.
- Type: Qualitative Nominal
- Classes: Carpet, Hard, Grass, or Clay.

### `in_out`
- Indicates whether the match was played indoors or outdoors.
- Type: Qualitative Nominal
- Classes: Indoor or Outdoor.

### `p1_rank`, `p2_rank`, `rank_dif`
- The rankings of Player 1 and Player 2, respectively, 1 month before the match. Also, the absolute difference between those rankings.
- Type: Quantitative Discrete

### `p1_rank_move`, `p2_rank_move`
- The change in rankings for Player 1 and Player 2 from three months prior to the match to the match date.
- Type: Quantitative Discrete ❓

### `p1_wins`, `p2_wins`
- The total career matches won count for Player 1 and Player 2, respectively, as of October 2023.
- Type: Quantitative Discrete ❓

### `p1_wl_ratio`, `p2_wl_ratio`, `wl_dif`
- The win-loss ratio for Player 1’s and Player 2’s career as of October 2023. Also, the absolute difference between the two.
- Type: Quantitative Continuous ❓

### `p1_titles`, `p2_titles`, `titles_dif`
- The total titles won by Player 1 and Player 2 as of October 2023. Also, the absolute difference between the two.
- Type: Quantitative Discrete ❓

### `p1_age`, `p2_age`, `age_dif`
- The age of Player 1 and Player 2 at the time of the match. Also, the absolute difference between the two.
- Type: Quantitative Discrete ❓

### `p1_height`, `p2_height`, `height_dif`
- The height of Player 1 and Player 2. Also, the absolute difference between the two.
- Type: Quantitative Discrete ❓

### `p1_weight`, `p2_weight`, `weight_dif`
- The weight of Player 1 and Player 2. Also, the absolute difference between the two.
- Type: Quantitative Discrete ❓

### `p1_hand`, `p2_hand`
- The playing hand for Player 1 and Player 2.
- Type: Qualitative Nominal
- Classes: Right-handed, Left-handed, or Ambidextrous.

### `p1_backhand`, `p2_backhand`
- The style of backhand for Player 1 and Player 2.
- Type: Qualitative Nominal
- Classes: One-handed backhand or Two-handed backhand.

### `p1_nat`, `p2_nat`
- The nationality of Player 1 and Player 2 represented by the country’s code.
- Type: Qualitative Nominal
- Classes: AUS, PRT, RUS, or ...

### `number_of_sets`
- The number of sets played in the match.
- Type: Qualitative Ordinal ❓
- Classes: 0, 1, 2, 3, 4, or 5.


