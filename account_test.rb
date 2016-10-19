#!/usr/bin/ruby

require './account'

tx = {
  "inputs" => [
    {
      "address" => "abc",
      "value" => 6
    },
    {
      "address" => "def",
      "value" => 4
    },
    {
      "address" => "ghi",
      "value" => 3
    }
  ],
  "outputs" => [
    {
      "address" => "jkl",
      "value" => 2
    },
    {
      "address" => "mno",
      "value" => 2
    },
    {
      "address" => "pqr",
      "value" => 1
    }
  ]
}

addresses = %w[ abc mno xyz ]

my_wallet = Account.new(addresses)

xfer = my_wallet.filter_mine(tx)

puts xfer
