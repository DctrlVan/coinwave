#!/usr/bin/ruby

require './lib/account'
require './util/sample_tx'

addresses = %w[ abc mno xyz ]

my_wallet = Account.new(addresses)

my_wallet.filter_save(SampleTx.new.tx)

my_wallet.accounts.each do |account|
  puts account
end
 
