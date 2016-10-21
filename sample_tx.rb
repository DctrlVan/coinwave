class SampleTx
  attr_reader :tx

  def initialize
    @tx = {
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
  end
end
