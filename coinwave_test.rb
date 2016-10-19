#!/usr/bin/env ruby
#
# Coinwave - Scan the blockchain for transactions, convert to local currency
#            and create a wave importable csv file.
#    Usage - ./Coinwave <btc_address> >output.csv
#
# price_source="https://api.bitcoinaverage.com/history/CAD/per_hour_monthly_sliding_window.csv"

require './coinwave.rb'
require 'satoshi-unit'

# TODO: Test for absent argument(s)

#TODO: Write isMine() method for determining how much of each
#      transaction is recombining or pay-to-self etc.

accounts=Coinwave.new(ARGV[0], ARGV[1])
#accounts.fetch_lookup

amount = Satoshi.new(1) # 1 bitcoin.
puts accounts.to_fiat(amount.to_i, "2015-11-17")

#accounts.convert_batch
#accounts.save_lookup
