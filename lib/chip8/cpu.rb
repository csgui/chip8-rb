require_relative 'memory'
require_relative 'registers'

module Chip8
  class CPU

    attr_accessor :memory, :pc, :registers, :stack

    def initialize
      @pc = 0x200 # Program starts at 0x200 memory position
      @registers = Registers.new
      @stack = Array.new(0x10, 0x0)
      @i = 0x0
      @halted = false
    end

    def halt
      @halted = true
    end

    def emulate
      cycle while not @halted
    end

    # The CPU instruction cycle.
    def cycle
      fetch
      decode
      execute
    end

    private

    # In this step, the emulator will fetch one opcode from the memory
    # at the location specified by the program counter (pc).
    #
    # Memory is represented as an array in which each address contains one byte.
    #
    # As one opcode is 2 bytes long, we need to fetch two successive bytes
    # and merge them, using a bitwise OR operation, to get the actual opcode.
    def fetch
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
      when 0x1 # Jump to instruction at memory location nnn.
        @pc = @nnn
      when 0x2 # Calls a subroutine at memory location nnn.
        @stack.push(@pc)
        @pc = @nnn
      when 0x3 # Skips the next instruction if VX equals NN.
        @pc += 0x2 if @registers[@x] == @nn
      when 0x4 # Skips the next instruction if VX doesn't equal NN.
        @pc += 0x2 if @registers[@x] != @nn
      when 0x5 # Skips the next instruction if VX equals VY.
        @pc += 0x2 if @registers[@x] == @registers[@y]
      when 0x6 # Sets VX to NN.
        @registers[@x] = @nn
      when 0x7 # Adds NN to VX.
        @registers[@x] += @nn
      end

    end # end execute

  end
end
