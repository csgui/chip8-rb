require_relative 'memory'
require_relative 'registers'

module Chip8
  class CPU

    attr_accessor :memory, :pc, :registers, :stack

    def initialize
      @pc = 0x200 # Program starts at 0x200 memory position
      @registers = Registers.new
      @stack = Array.new
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
      when 0x8
        case (@opcode & 0x000F)
        when 0x0 # Sets VX to VY.
          @registers[@x] = @registers[@y]
        when 0x1 # Performs a bitwise OR on the values of VX and VY.
          @registers[@x] |= @registers[@y]
        when 0x2 # Performs a bitwise AND on the values of VX and VY.
          @registers[@x] &= @registers[@y]
        when 0x3 # Performs a bitwise XOR on the values of VX and VY.
          @registers[@x] ^= @registers[@y]
        when 0x4
          # The values of VX and VY are added together.
          # If the result is greater than 8 bits (i.e., > 255,) VF is set to 1, otherwise 0.
          # Only the lowest 8 bits of the result are kept, and stored in VX.
          @registers[0xF] = @registers[@x] + @registers[@y] > 0xFF ? 0x1 : 0x0
          @registers[@x] = (@registers[@x] + @registers[@y]) & 0x00FF
        when 0x5
          # VY is subtracted from VX.
          # VF is set to 0 when there's a borrow, and 1 when there isn't.
          @registers[0xF] = @registers[@x] >= @registers[@y] ? 0x1 : 0x0
          @registers[@x] = (@registers[@x] - @registers[@y]) & 0x00FF
        when 0x6
          # If the least-significant bit of VX is 1, then VF is set to 1, otherwise 0.
          # Then VX is divided by 2.
          @registers[0xF] = (@registers[@x] & 0x1) == 0x1 ? 0x1 : 0x0
          @registers[@x] >>= 1
        when 0x7
          # VX is subtracted from VY.
          # VF is set to 0 when there's a borrow, and 1 when there isn't.
          @registers[0xF] = @registers[@y] >= @registers[@x] ? 0x1 : 0x0
          @registers[@x] = (@registers[@y] - @registers[@x]) & 0x00FF
        when 0xE
          # If the most-significant bit of VX is 1, then VF is set to 1, otherwise to 0.
          # Then VX is multiplied by 2.
          @registers[0xF] = (@registers[@x] >> 0x7) == 0x1 ? 0x1 : 0x0
          @registers[@x] <<= 1
        end
      end

    end # end execute

  end
end
