require_relative 'memory'
require_relative 'registers'

module Chip8
  class CPU

    attr_accessor :memory, :vdp, :pc, :registers, :stack, :i, :dt, :st

    # TODO Change this implementation to a proper class
    attr_accessor :vram, :keyboard

    def initialize
      @pc = 0x200 # Program starts at 0x200 memory position
      @registers = Registers.new
      @stack = Array.new
      @i = 0x0
      @halted = false
      @dt = 0x0
      @st = 0x0
      @keyboard = Array.new
      @vram = {:x => 0, :y => 0, :sprite => Array.new(0xF, 0x0)}
      # vram[:sprite] = [0x3C,0x24,0xE7,0x66,0xE7,0x3C,0x18,0x18,0x18,0x18,0x18,0x18,0x3C]
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
      puts "DEBUG: #{@opcode.to_s(16)}"
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
      @pc += 2

      if @opcode == 0x00EE
        puts "DEBUG: Returns from a subroutine"
        puts "DEBUG: PC = #{@pc.to_s(16)} STACK = #{@stack}"
        puts "DEBUG: Execute instruction"
        @pc = @stack.pop
        puts "DEBUG: PC = #{@pc.to_s(16)} STACK = #{@stack}"
        puts
      end

      if @opcode == 0x00E0
        puts "DEBUG: Clear screen"
        puts "DEBUG: VRAM = #{vdp.vram}"
        puts "DEBUG: Execute instruction"
        (0..32).each do |i|
          (0..64).each do |j|
            vdp.set_pixel(j, i, 0x0)
          end
        end
        puts "DEBUG: VRAM = #{vdp.vram}"
        puts
      end

      case (@opcode & 0xF000) >> 12
      when 0x1 # Jump to instruction at memory location nnn.
        puts "DEBUG: Jump to instruction at memory location NNN"
        puts "DEBUG: PC = #{@pc.to_s(16)} NNN = #{@nnn.to_s(16)}"
        puts "DEBUG: Execute instruction"
        @pc = @nnn
        puts "DEBUG: PC = #{@pc.to_s(16)} NNN = #{@nnn.to_s(16)}"
        puts
      when 0x2 # Calls a subroutine at memory location nnn.
        puts "DEBUG: Calls a subroutine at memory location NNN"
        puts "DEBUG: PC = #{@pc.to_s(16)} NNN = #{@nnn.to_s(16)} STACK = #{@stack}"
        puts "DEBUG: Execute instruction"
        @stack.push(@pc)
        @pc = @nnn
        puts "DEBUG: PC = #{@pc.to_s(16)} NNN = #{@nnn.to_s(16)} STACK = #{@stack}"
        puts
      when 0x3 # Skips the next instruction if VX equals NN.
        puts "DEBUG: Skips the next instruction if VX equals NN"
        puts "DEBUG: PC = #{@pc.to_s(16)} NN = #{@nn.to_s(16)} VX = #{@registers[@x]}"
        puts "DEBUG: Execute instruction"
        @pc += 0x2 if @registers[@x] == @nn
        puts "DEBUG: PC = #{@pc.to_s(16)} NN = #{@nn.to_s(16)} VX = #{@registers[@x]}"
        puts
      when 0x4 # Skips next instruction if VX doesn't equal NN
        puts "DEBUG: Skips the next instruction if VX doesn't equal NN"
        puts "DEBUG: PC = #{@pc.to_s(16)} NN = #{@nn.to_s(16)} VX = #{@registers[@x]}"
        puts "DEBUG: Execute instruction"
        @pc += 0x2 if @registers[@x] != @nn
        puts "DEBUG: PC = #{@pc.to_s(16)} NN = #{@nn.to_s(16)} VX = #{@registers[@x]}"
        puts
      when 0x5 # Skips next instruction if VX equals VY.
        puts "DEBUG: Skips the next instruction if VX equals VY"
        puts "DEBUG: PC = #{@pc.to_s(16)} VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
        puts "DEBUG: Execute instruction"
        @pc += 0x2 if @registers[@x] == @registers[@y]
        puts "DEBUG: PC = #{@pc.to_s(16)} VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
        puts
      when 0x6 # Sets VX to NN.
        puts "DEBUG: Sets VX to NN"
        puts "DEBUG: REGISTERS = #{@registers.v} X = #{@x.to_s(16)} NN = #{@nn.to_s(16)}"
        puts "DEBUG: Execute instruction"
        @registers[@x] = @nn
        puts "DEBUG: REGISTERS = #{@registers.v} X = #{@x.to_s(16)} NN = #{@nn.to_s(16)}"
        puts
      when 0x7 # Adds NN to VX.
        puts "DEBUG: Adds NN to VX"
        puts "DEBUG: REGISTERS = #{@registers.v} X = #{@x.to_s(16)} VX = #{@registers[@x].to_s(16)} NN = #{@nn.to_s(16)}"
        puts "DEBUG: Execute instruction"
        @registers[@x] += @nn
        puts "DEBUG: REGISTERS = #{@registers.v} X = #{@x.to_s(16)} VX = #{@registers[@x].to_s(16)} NN = #{@nn.to_s(16)}"
        puts
      when 0x8
        case (@opcode & 0x000F)
        when 0x0 # Sets VX to VY.
          puts "DEBUG: Sets VX to VY"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[@x] = @registers[@y]
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts
        when 0x1 # Performs a bitwise OR on the values of VX and VY.
          puts "DEBUG: Performs a bitwise OR on the values of VX and VY"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[@x] |= @registers[@y]
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts
        when 0x2 # Performs a bitwise AND on the values of VX and VY.
          puts "DEBUG: Performs a bitwise AND on the values of VX and VY"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[@x] &= @registers[@y]
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts
        when 0x3 # Performs a bitwise XOR on the values of VX and VY.
          puts "DEBUG: Performs a bitwise XOR on the values of VX and VY"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[@x] ^= @registers[@y]
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
          puts
        when 0x4
          # The values of VX and VY are added together.
          # If the result is greater than 8 bits (i.e., > 255,) VF is set to 1, otherwise 0.
          # Only the lowest 8 bits of the result are kept, and stored in VX.
          puts "DEBUG: Add values of VX and VY. If the result is greater than 8 bits (i.e., > 255,) VF is set to 1, otherwise 0."
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[0xF] = @registers[@x] + @registers[@y] > 0xFF ? 0x1 : 0x0
          @registers[@x] = (@registers[@x] + @registers[@y]) & 0x00FF
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts
        when 0x5
          # VY is subtracted from VX.
          # VF is set to 0 when there's a borrow, and 1 when there isn't.
          puts "DEBUG: Subtract VY from VX"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[0xF] = @registers[@x] >= @registers[@y] ? 0x1 : 0x0
          @registers[@x] = (@registers[@x] - @registers[@y]) & 0x00FF
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts
        when 0x6
          # If the least-significant bit of VX is 1, then VF is set to 1, otherwise 0.
          # Then VX is divided by 2.
          puts "DEBUG: If the least-significant bit of VX is 1, then VF is set to 1, otherwise 0"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[0xF] = (@registers[@x] & 0x1) == 0x1 ? 0x1 : 0x0
          @registers[@x] = (@registers[@x] >> 1) & 0x00FF
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts
        when 0x7
          # VX is subtracted from VY.
          # VF is set to 0 when there's a borrow, and 1 when there isn't.
          puts "DEBUG: Subtract VY from VX"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[0xF] = @registers[@y] >= @registers[@x] ? 0x1 : 0x0
          @registers[@x] = (@registers[@y] - @registers[@x]) & 0x00FF
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts
        when 0xE
          # If the most-significant bit of VX is 1, then VF is set to 1, otherwise to 0.
          # Then VX is multiplied by 2.
          puts "DEBUG: If the most-significant bit of VX is 1, then VF is set to 1, otherwise to 0"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[0xF] = (@registers[@x] >> 0x7) == 0x1 ? 0x1 : 0x0
          @registers[@x] = (@registers[@x] << 1) & 0x00FF
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} VF = #{@registers[0xF].to_s(16)}"
          puts
        end
      when 0x9
        # Skip next instruction if VX != VY.
        puts "DEBUG: Skip next instruction if VX != VY"
        puts "DEBUG: PC = #{@pc.to_s(16)} VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
        puts "DEBUG: Execute instruction"
        @pc += 0x2 if @registers[@x] != @registers[@y]
        puts "DEBUG: PC = #{@pc.to_s(16)} VX = #{@registers[@x].to_s(16)} VY = #{@registers[@y].to_s(16)}"
        puts
      when 0xA
        # Sets I to NNN.
        puts "DEBUG: Set I to NNN"
        puts "DEBUG: I = #{@i.to_s(16)} NNN = #{@nnn.to_s(16)}"
        puts "DEBUG: Execute instruction"
        @i = @nnn
        puts "DEBUG: I = #{@i.to_s(16)} NNN = #{@nnn.to_s(16)}"
        puts
      when 0xB
        # Jump to location NNN + V0.
        puts "DEBUG: Jump to location NNN + V0"
        puts "DEBUG: PC = #{@pc.to_s(16)} NNN = #{@nnn.to_s(16)} V0 = #{@registers[0x0].to_s(16)}"
        puts "DEBUG: Execute instruction"
        @pc = @nnn + @registers[0x0]
        puts "DEBUG: PC = #{@pc.to_s(16)} NNN = #{@nnn.to_s(16)} V0 = #{@registers[0x0].to_s(16)}"
        puts
      when 0xC
        # Set Vx = random byte AND NN.
        puts "DEBUG: Set Vx = random byte AND NN"
        puts "DEBUG: VX = #{@registers[@x].to_s(16)} NN = #{@nn.to_s(16)}"
        puts "DEBUG: Execute instruction"
        @registers[@x] = rand(255) & @nn
        puts "DEBUG: VX = #{@registers[@x].to_s(16)} NN = #{@nn.to_s(16)}"
        puts
      when 0xD
        # Draw a sprite at position VX, VY with N bytes of sprite data
        # starting at the address stored in I.
        #
        # Set VF to 1 if any set pixels are changed to unset, and 0 otherwise.
        puts "DEBUG: Draw sprite"
        puts "DEBUG: I = #{@i.to_s(16)} N = #{@n.to_s(16)} X = #{@x.to_s(16)} Y = #{@y.to_s(16)} VF = #{@registers[0xF].to_s(16)}"
        puts "DEBUG: Execute instruction"
        sprite               = []
        sprite_address_start = @i
        sprite_address_end   = @i + (@n - 1)

        (sprite_address_start..sprite_address_end).each_with_index do |addr, i|
          sprite[i] = memory[addr]
        end

        # Drawing is done in XOR mode and if a pixel is turned off as a result of drawing,
        # the VF register is set. This is used for collision detection.
        pos_x = @registers[@x]
        pos_y = @registers[@y]
        collision_detected = false
        sprite.each_with_index do |byte, i|

          (0..7).each do |num|
            if (byte & (0x80 >> num)) != 0
              pixel = vdp.get_pixel(pos_x + num, pos_y + i)
              collision_detected = true if pixel == 1
              vdp.set_pixel(pos_x + num, pos_y + i, pixel ^= 1)
            end
          end
        end

        @registers[0xF] = collision_detected ? 0x1 : 0x0

        puts "DEBUG: I = #{@i.to_s(16)} N = #{@n.to_s(16)} X = #{@x.to_s(16)} Y = #{@y.to_s(16)} VF = #{@registers[0xF].to_s(16)}"
        puts
      when 0xE
        case @nn
        when 0x9E
          # Skip next instruction if key with the value of Vx is pressed.
          puts "DEBUG: Skip next instruction if key with the value of Vx is pressed"
          puts "DEBUG: PC = #{@pc.to_s(16)} KEYBOARD = #{@keyboard} VX = #{@registers[@x].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @pc += 2 if @keyboard[@registers[@x]] == 1
          puts "DEBUG: PC = #{@pc.to_s(16)} KEYBOARD = #{@keyboard} VX = #{@registers[@x].to_s(16)}"
          puts
        when 0xA1
          # Skip next instruction if key with the value of Vx is not pressed.
          puts "DEBUG: Skip next instruction if key with the value of Vx is not pressed"
          puts "DEBUG: PC = #{@pc.to_s(16)} KEYBOARD = #{@keyboard} VX = #{@registers[@x].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @pc += 2 if @keyboard[@registers[@x]] == 0
          puts "DEBUG: PC = #{@pc.to_s(16)} KEYBOARD = #{@keyboard} VX = #{@registers[@x].to_s(16)}"
          puts
        end
      when 0xF
        case @nn
        when 0x07
          # Store the current value of the delay timer in register VX.
          puts "DEBUG: Store the current value of the delay timer in register VX"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} DT = #{@dt.to_s(16)}"
          puts "DEBUG: Execute instruction"
          @registers[@x] = @dt
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} DT = #{@dt.to_s(16)}"
          puts
        when 0x0A
          # Wait for a key press, store the value of the key in Vx.
          puts "DEBUG: Wait for a key press, store the value of the key in VX"
          puts "DEBUG: PC = #{@pc.to_s(16)} KEYBOARD = #{@keyboard} VX = #{@registers[@x].to_s(16)}"
          puts "DEBUG: Execute instruction"
          require 'pry'; binding.pry
          @keyboard[1] != 0 ? @registers[@x] = @keyboard[@x] : @pc -= 2
          puts "DEBUG: PC = #{@pc.to_s(16)} KEYBOARD = #{@keyboard} VX = #{@registers[@x].to_s(16)}"
          puts
        when 0x15
          # Set delay timer to the value of register VX.
          puts "DEBUG: Set delay timer to the value of register VX"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} DT = #{@dt.to_s(16)}"
          puts "DEBUG: Execute instruction"
          @dt = @registers[@x]
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} DT = #{@dt.to_s(16)}"
          puts
        when 0x18
          # Set the sound timer to the value of register VX.
          puts "DEBUG: Set the sound timer to the value of register VX"
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} ST = #{@st.to_s(16)}"
          puts "DEBUG: Execute instruction"
          @st = @registers[@x]
          puts "DEBUG: VX = #{@registers[@x].to_s(16)} ST = #{@st.to_s(16)}"
          puts
        when 0x1E
          # Add the value stored in register VX to register I.
          puts "DEBUG: Add the value stored in register VX to register I"
          puts "DEBUG: I = #{@i.to_s(16)} VX = #{@registers[@x].to_s(16)} X = #{@x.to_s(16)}"
          puts "DEBUG: Execute instruction"
          @i += @registers[@x]
          puts "DEBUG: I = #{@i.to_s(16)} VX = #{@registers[@x].to_s(16)} X = #{@x.to_s(16)}"
          puts
        when 0x29
          # Sets I to the location of the sprite for the character in VX.
          puts "DEBUG: Sets I to the location of the sprite for the character in VX"
          puts "DEBUG: I = #{@i.to_s(16)} VX = #{@registers[@x].to_s(16)}"
          puts "DEBUG: Execute instruction"
          @i = @registers[@x] * 5
          puts "DEBUG: I = #{@i.to_s(16)} VX = #{@registers[@x].to_s(16)}"
          puts
        when 0x33
          # Stores the Binary-coded decimal representation of VX
          # at memory addresses I, I + 1 and I + 2.
          puts "DEBUG: Store BCD"
          puts "DEBUG: I = #{@i.to_s(16)} VX = #{@registers[@x].to_s(16)}"
          puts "DEBUG: Execute instruction"
          memory[@i] = registers[@x] / 100
          memory[@i + 1] = (registers[@x] / 10) % 10
          memory[@i + 2] = registers[@x] % 10
          puts "DEBUG: I = #{@i.to_s(16)} VX = #{@registers[@x].to_s(16)}"
          puts
        when 0x55
          # Store registers V0 through VX in memory starting at location I.
          puts "DEBUG: Store registers V0 through VX in memory starting at location I"
          puts "DEBUG: Execute instruction"
          (0..@x).each { |r| memory[@i + r] = @registers[r] }
          puts
        when 0x65
          # Read registers V0 through VX from memory starting at location I.
          puts "DEBUG: Read registers V0 through VX from memory starting at location I"
          puts "DEBUG: Execute instruction"
          (0..@x).each { |r| @registers[r] = memory[@i + r] }
          puts
        end
      end

    end # end execute

  end
end
