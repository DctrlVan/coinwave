# Coinwave

Blockchain Scraper for Wave Apps.

Run periodically to create a Wave importable csv file from a given address.
Read the code, it's not that scary.

## Usage

`./coinwave <btc_address> >output.csv`

Note: The current incarnation expects to find the following data file in the repo root directory:
"per_hour_monthly_sliding_window.csv"
Get it for your local currency by running:
`wget https://api.bitcoinaverage.com/history/<ISO currency_code>/per_hour_monthly_sliding_window.csv`
