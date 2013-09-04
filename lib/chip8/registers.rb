module Chip8

  # CHIP-8 has 16 8-bit data registers named from V0 to VF.
  # The VF register doubles as a carry flag.
  class Registers
    attr_accessor :v

    def initialize
      @v = Array.new(0x10, 0x0)
    end
  end
end
