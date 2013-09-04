require_relative 'registers'
require_relative 'memory'

module Chip8

  class CPU
    attr_accessor :registers, :memory

    def initialize
      @memory = Memory.new
      @registers = Registers.new
      @i = 0x0
      @pc = 0x200 # Program starts at 0x200 memory position
      @halted = false
    end

    def halt
      @halted = true
    end

    def run
      cycle while not @halted
    end

    private

    def cycle
      fetch
      decode
      execute
      @pc += 2
    end

    def fetch
      # memory is represented as an array in which each address contains one byte.
      # As one opcode is 2 bytes long, we need to fetch two successive bytes
      # and merge them to get the actual opcode.
      @opcode = (memory[@pc] << 8) | memory[@pc + 1]
    end

    def decode
      # address. A 12-bit value, the lowest 12 bits of the instruction
      @nnn = @opcode & 0x0FFF
      # byte. An 8-bit value, the lowest 8 bits of the instruction
      @nn = @opcode & 0x00FF
      # nibble. A 4-bit value, the lowest 4 bits of the instruction
      @n = @opcode & 0x000F
      # register X. A 4-bit value, the lower 4 bits of the high byte of the instruction
      @x = (@opcode & 0x0F00) >> 8
      #register Y. A 4-bit value, the upper 4 bits of the low byte of the instruction
      @y = (@opcode & 0x00F0) >> 4
    end

    def execute
      case (@opcode & 0xF000) >> 12
      when 0x1 # Jump to location nnn.
        @pc = @nnn
      end
    end

  end
end
