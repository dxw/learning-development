# Learning and Development
This repository is a collection of scripts for getting information about learning and development spending out of BreatheHR and then processing it.

It was made for dxw's Makers' Days, 15-16 July 2021.

## Usage

### Breathe to Google Sheets
`bundle exec ruby google_sheets.rb` to extract all L&D data from Breath to a specified Google Sheet

### Slackbot
- Add your email to the `our_email` array in `get_breathe_user_data` in `lib/learningbot/client.rb` to receive Slackbot messages without pinging everyone.
- You can run this with `bundle exec ruby lib/learningbot.rb`.

## Installation
1. Install prerequisites by running `bundle install`.
2. Copy the `.env.example` file to `.env,` and update. You can find Breathe API keys and Google Service Account details on 1Password.

## Limitations
- Breathe's data is not great. Many entries lack a date, which makes it difficult to look at spending within a specific time period.
- Exchange rate data is current rather than for the time the purchase was actually made, so conversions don't accurately show how much of someone's L&D budget was spent
