class Account
  attr_accessor :addresses

  def initialize(addresses)
    @accounts = []
    @addresses = addresses
  end

  def filter_mine(tx)
    inbound = tx["outputs"]
      .select { |index| @addresses.include?(index["address"]) }
      .map { |pair| pair["value"] }
      .reduce(:+)

    outbound = tx["inputs"]
      .select { |index| @addresses.include?(index["address"]) }
      .map { |pair| pair["value"] }
      .reduce(:+)

    xfer = inbound - outbound
  end

  def filter_save(tx)
    xfer = filter(tx)
    @accounts << xfer
  end
end

