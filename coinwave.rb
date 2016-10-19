require 'open-uri'
require 'json'
require 'csv'
require 'bitcoin'

class Coinwave
  attr_accessor :address, :code

  def initialize(address, code)
    Bitcoin::valid_address?(address) or raise 'Bitcoin address was not valid.'
    @address = address
    @code = code ? code : "USD"
    @lookup="lookup.#{@code}.json"
    @price_hash=load_local
  end

  def get_price(txts)
    tx_timestamp = normalize(3600, txts)
    unless @price_hash.key?(tx_timestamp)
      tx_timestamp = normalize(86400, txts)
    end
    @price_hash[tx_timestamp]
  end

  def to_s
    convert_batch
  end

  def load_local
    if File.file?(@lookup)
      lookup_file = File.open(@lookup, 'r')
      return JSON.load(lookup_file)
    else
      return {}
    end
  end

  # Fetch API data into ary of arys
  def process_data(url, timespan)
    open(url) do |stream|
      prices = CSV.new(stream)
      prices.gets
      prices.each do |row|
        #old_date = DateTime.parse(row[0]).strftime("%s").to_i
        norm_ts = normalize(timespan, row[0])
        @price_hash[norm_ts] = row[3]
      end
    end
  end

  def fetch_lookup

    #TODO: Be more defensive here in the case of net request & filesystem issues.
    #TODO: Derive separate save paths lookups from currency codes.
    daily_url = URI.parse(
      "https://api.bitcoinaverage.com/history/#{@code}/per_day_all_time_history.csv")
		File.open("per_day_all_time_history.csv", "wb") do |saved_file|
			open(daily_url, "rb") do |read_file|
        # The jokers at bitcoinaverage are sending half unix, half dos encoded csvs :-/ 
				saved_file.write(read_file.read.encode(universal_newline: true))
			end
		end

    # Repeat for the more accurate hourly data (covers prior month only).
    hourly_url = URI.parse(
      "https://api.bitcoinaverage.com/history/#{@code}/per_hour_monthly_sliding_window.csv")
		File.open("per_hour_monthly_sliding_window.csv", "wb") do |saved_file|
			open(hourly_url, "rb") do |read_file|
				saved_file.write(read_file.read.encode(universal_newline: true))
			end
		end

    #daily_url = "https://api.bitcoinaverage.com/history/#{@code}/per_day_all_time_history.csv"
    #hourly_url = "https://api.bitcoinaverage.com/history/#{@code}/per_hour_monthly_sliding_window.csv"
    
    # Order is important here, we want the more accurate hourly
    # data to clobber any coincidental daily average data.
    daily_url = "per_day_all_time_history.csv"
    process_data(daily_url, 86400)

    #@price_hash.merge(load_local)

    hourly_url = "per_hour_monthly_sliding_window.csv"
    process_data(hourly_url, 3600)
  end

  def save_lookup(dest=@lookup)
    serialized = JSON.generate(@price_hash)
    File.write("#{dest}", serialized)
  end

  # Fetch bitcoin transactions for address.
  def fetch_txs
    return URI.parse(
      "https://bitcoin.toshi.io/api/v0/addresses/#{@address}/transactions?limit=2000")
  end

  # Round the timestamps in lookup tables.
  def normalize(accuracy, txts)
    old_date = DateTime.parse(txts)
    old_timestamp = old_date.strftime("%s").to_i - (old_date.strftime("%s").to_i % accuracy)
    return old_timestamp.to_s
  end

  # In-place convert a load of csv-ish data to local currency.
  def convert_batch
    #TODO: Take a datastructure param instead of calling fetch_txs().
    puts "date,amount,desc"
    uri=fetch_txs
    uri.open do |json|
      txs = JSON.load(json)
      txs["transactions"].each do |tx| 
        if tx["block_branch"] == "main"
          tx["outputs"].each do |output|
            if output["addresses"][0] == @address
              # Note: it could be hours between blocks, should we really use the
              # block timestamp for rate lookup?
              local_value = to_fiat(output["amount"] ,tx["block_time"])
              date = DateTime.parse(tx["block_time"])
              line = [ date.strftime("%Y/%m/%d"), local_value.round(2).to_s, tx["hash"] ].join(",")
              #TODO: Return a datastructure to caller rather than printing to stdout.
              puts line
            end
          end
        end
      end
    end
  end

  # Return the local price for a given btc amount and timestamp.
  def to_fiat(amt, txts)
    price = get_price(txts).to_i
    amt.to_i * price / 100000000.0
  end

end
