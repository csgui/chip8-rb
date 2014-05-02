module Emul8
  class Memory

    attr_accessor :vdp

    # Memory size
    # 4096 bytes, 4KB
    RAM_SIZE = 0x1000

    # Offset
    PROGRAM_OFFSET = 0x200

    # Built-in font set.
    # Fonts are sprites that represents the
    # hexadecimal digits 0 through F.
    FONT_SET = [
      0xF0,0x90,0x90,0x90,0xF0, #0
      0x20,0x60,0x20,0x20,0x70, #1
      0xF0,0x10,0xF0,0x80,0xF0, #2
      0xF0,0x10,0xF0,0x10,0xF0, #3
      0x90,0x90,0xF0,0x10,0x10, #4
      0xF0,0x80,0xF0,0x10,0xF0, #5
      0xF0,0x80,0xF0,0x90,0xF0, #6
      0xF0,0x10,0x20,0x40,0x50, #7
      0xF0,0x90,0xF0,0x90,0xF0, #8
      0xF0,0x90,0xF0,0x10,0xF0, #9
      0xF0,0x90,0xF0,0x90,0x90, #A
      0xE0,0x90,0xE0,0x90,0xE0, #B
      0xF0,0x80,0x80,0x80,0xF0, #C
      0xE0,0x90,0x90,0x90,0xE0, #D
      0xF0,0x80,0xF0,0x80,0xF0, #E
      0xF0,0x80,0xF0,0x80,0x80  #F
    ]

    def initialize
      @page = Array.new(RAM_SIZE, 0x0)
      load_font_set
    end

    def [](address)
      @page[address]
    end

    def []=(address, value)
      @page[address] = value
    end

    def load bytecode
      bytecode.each_with_index do |byte, i|
        self[PROGRAM_OFFSET + i] = byte
      end
    end

  private

    def load_font_set
      FONT_SET.each_with_index { |byte, i| self[i] = byte }
    end
  end
end