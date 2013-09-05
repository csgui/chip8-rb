module Chip8
  class Memory

    def initialize
      @page = Array.new(0x1000, 0x0)
    end

    def load(rom)
      File.open(rom, 'rb') { |f| f.read }.unpack('C*').each_with_index do |byte, i|
        @page[0x200 + i] = byte
      end
    end

    def [](address)
      @page[address]
    end
  end
end
