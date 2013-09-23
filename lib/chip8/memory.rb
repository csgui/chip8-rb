module Chip8
  class Memory

    PROGRAM_OFFSET = 0x200

    def initialize
      @page = Array.new(0x1000, 0x0)
    end

    def [](address)
      @page[address]
    end

    def load(bytecode)
      bytecode.each_with_index do |byte, i|
        @page[PROGRAM_OFFSET + i] = byte
      end
    end

  end
end
