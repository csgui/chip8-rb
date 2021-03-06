require File.expand_path('../../test_helper', __FILE__)
require 'chip8/cpu'

describe Chip8::CPU do

  let(:cpu) { Chip8::CPU.new }

  describe '#cycle' do

    describe 'fetch opcode' do
      before do
        cpu.memory = []
        cpu.memory[0x200] = 0x12
        cpu.memory[0x201] = 0x25

        cpu.cycle
      end

      after do
        cpu.pc = 0x200
      end

      it 'set @opcode from memory values' do
        expected_opcode = 0x1225
        cpu.instance_variable_get(:@opcode).must_equal(expected_opcode)
      end
    end

    describe 'decode opcode' do
      before do
        cpu.memory = []
        cpu.memory[0x200] = 0x12
        cpu.memory[0x201] = 0x25

        cpu.cycle
      end

      after do
        cpu.pc = 0x200
      end

      it 'set the lowest 12 bits of the opcode to @nnn' do
        expected_address = 0x225
        cpu.instance_variable_get(:@nnn).must_equal(expected_address)
      end

      it 'set the lowest 8 bits of the opcode to @nn' do
        expected_byte = 0x25
        cpu.instance_variable_get(:@nn).must_equal(expected_byte)
      end

      it 'set the lowest 4 bits of the opcode to @n' do
        expected_nibble = 0x5
        cpu.instance_variable_get(:@n).must_equal(expected_nibble)
      end

      it 'set the lower 4 bits of the high opcode byte to register X' do
        expected_x = 0x2
        cpu.instance_variable_get(:@x).must_equal(expected_x)
      end

      it 'set the upper 4 bits of the low opcode byte to register Y' do
        expected_y = 0x2
        cpu.instance_variable_get(:@y).must_equal(expected_y)
      end
    end

    describe 'execute opcode' do
      after do
        cpu.pc = 0x200
      end

      describe 'instruction 0x1NNN' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x12
          cpu.memory[0x201] = 0x25

          cpu.cycle
        end

        it 'set PC to NNN' do
          cpu.pc.must_equal(0x225)
        end
      end

      describe 'instruction 0x2NNN' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x22
          cpu.memory[0x201] = 0x31

          cpu.cycle
        end

        it 'puts the current PC on the top of the stack' do
          cpu.stack.pop.must_equal(0x200)
        end

        it 'set PC to NNN' do
          cpu.pc.must_equal(0x231)
        end
      end

      describe 'instruction 0x3XNN' do
        it 'skip next instruction if VX is equal NN' do
          cpu.memory = []
          cpu.memory[0x200] = 0x35
          cpu.memory[0x201] = 0x11
          cpu.registers[0x5] = 0x11
          cpu.cycle

          cpu.pc.must_equal(0x202)
        end

        it 'not skip next instruction if VX is not equal NN' do
          cpu.memory = []
          cpu.memory[0x200] = 0x35
          cpu.memory[0x201] = 0x11
          cpu.registers[0x5] = 0x12
          cpu.cycle

          cpu.pc.must_equal(0x200)
        end
      end

      describe 'instruction 0x4XNN' do
        it 'skip next instruction if VX is not equal NN' do
          cpu.memory = []
          cpu.memory[0x200] = 0x45
          cpu.memory[0x201] = 0x11
          cpu.registers[0x5] = 0x12
          cpu.cycle

          cpu.pc.must_equal(0x202)
        end

        it 'not skip next instruction if VX is equal NN' do
          cpu.memory = []
          cpu.memory[0x200] = 0x45
          cpu.memory[0x201] = 0x11
          cpu.registers[0x5] = 0x11
          cpu.cycle

          cpu.pc.must_equal(0x200)
        end
      end

      describe 'instruction 0x5XY0' do
        it 'skip next instruction if VX is equal VY' do
          cpu.memory = []
          cpu.memory[0x200] = 0x53
          cpu.memory[0x201] = 0x20
          cpu.registers[0x3] = 0x1
          cpu.registers[0x2] = 0x1
          cpu.cycle

          cpu.pc.must_equal(0x202)
        end

        it 'not skip next instruction if VX is not equal VY' do
          cpu.memory = []
          cpu.memory[0x200] = 0x53
          cpu.memory[0x201] = 0x20
          cpu.registers[0x3] = 0x1
          cpu.registers[0x2] = 0x2
          cpu.cycle

          cpu.pc.must_equal(0x200)
        end
      end

      describe 'instruction 0x6XNN' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x62
          cpu.memory[0x201] = 0x33
          cpu.cycle
        end

        it 'sets VX to NN' do
          cpu.registers[0x2].must_equal(0x33)
        end
      end

      describe 'instruction 0x7XNN' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x75
          cpu.memory[0x201] = 0x36
          cpu.registers[0x5] = 0x1
          cpu.cycle
        end

        it 'Adds the value NN to the value of register VX' do
          cpu.registers[0x5].must_equal(0x37)
        end
      end

      describe 'instruction 0x8XY0' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x85
          cpu.memory[0x201] = 0x30
          cpu.registers[0x3] = 0xA
          cpu.cycle
        end

        it 'stores the value of register VY in register VX.' do
          cpu.registers[0x5].must_equal(0xA)
        end
      end

      describe 'instruction 0x8XY1' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x82
          cpu.memory[0x201] = 0x51
          cpu.registers[0x2] = 0xA
          cpu.registers[0x5] = 0xD
          cpu.cycle
        end

        it 'performs a bitwise OR on the values of VX and VY' do
          cpu.registers[0x2].must_equal(0xF)
        end
      end

      describe 'instruction 0x8XY2' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x82
          cpu.memory[0x201] = 0x52
          cpu.registers[0x2] = 0xA
          cpu.registers[0x5] = 0xD
          cpu.cycle
        end

        it 'performs a bitwise AND on the values of VX and VY' do
          cpu.registers[0x2].must_equal(0x8)
        end
      end

      describe 'instruction 0x8XY3' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x82
          cpu.memory[0x201] = 0x53
          cpu.registers[0x2] = 0xA
          cpu.registers[0x5] = 0xD
          cpu.cycle
        end

        it 'performs a bitwise XOR on the values of VX and VY' do
          cpu.registers[0x2].must_equal(0x7)
        end
      end

      describe 'instruction 0x8XY4' do
        it 'set VF to 0x0 if the sum of VX and VY is less than 8 bits (< 255)' do
          cpu.memory = []
          cpu.memory[0x200] = 0x83
          cpu.memory[0x201] = 0x74
          cpu.registers[0x3] = 0xA
          cpu.registers[0x7] = 0xD
          cpu.cycle

          cpu.registers[0xF].must_equal(0x0)
        end

        it 'set VF to 0x1 if the sum of VX and VY is greater than 8 bits (> 255)' do
          cpu.memory = []
          cpu.memory[0x200] = 0x83
          cpu.memory[0x201] = 0x74
          cpu.registers[0x3] = 0xAB
          cpu.registers[0x7] = 0xBA
          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'store only the lowest 8 bits of the result in VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0x83
          cpu.memory[0x201] = 0x74
          cpu.registers[0x3] = 0xCD
          cpu.registers[0x7] = 0xAA
          cpu.cycle

          cpu.registers[0x3].must_equal(0x77)
        end
      end

      describe 'instruction 0x8XY5' do
        it 'set VF to 0x0 if VX is less than VY' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x65
          cpu.registers[0x1] = 0xA
          cpu.registers[0x6] = 0xE
          cpu.cycle

          cpu.registers[0xF].must_equal(0x0)
        end

        it 'set VF to 0x1 if VX is greater than VY' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x75
          cpu.registers[0x1] = 0xC
          cpu.registers[0x7] = 0xB
          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'set VF to 0x1 if VX is equal VY' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x75
          cpu.registers[0x1] = 0xC
          cpu.registers[0x7] = 0xC
          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'store only the lowest 8 bits of the result in VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0x84
          cpu.memory[0x201] = 0x25
          cpu.registers[0x4] = 0xCCC
          cpu.registers[0x2] = 0xAA
          cpu.cycle

          cpu.registers[0x4].must_equal(0x22)
        end
      end

      describe 'instruction 0x8XY6' do
        it 'set VF to 0x1 if the least-significant bit of VX is 1' do
          cpu.memory = []
          cpu.memory[0x200] = 0x83
          cpu.memory[0x201] = 0x16
          cpu.registers[0x3] = 0x6F
          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'set VF to 0x0 if the least-significant bit of VX is 0' do
          cpu.memory = []
          cpu.memory[0x200] = 0x83
          cpu.memory[0x201] = 0x16
          cpu.registers[0x3] = 0x6E
          cpu.cycle

          cpu.registers[0xF].must_equal(0x0)
        end

        it 'shifts VX right by one' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x76
          cpu.registers[0x1] = 0xA
          cpu.cycle

          cpu.registers[0x1].must_equal(0x5)
        end
      end

      describe 'instruction 0x8XY7' do
        it 'set VF to 0x0 if VY is less than VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x67
          cpu.registers[0x1] = 0xE
          cpu.registers[0x6] = 0xA
          cpu.cycle

          cpu.registers[0xF].must_equal(0x0)
        end

        it 'set VF to 0x1 if VY is greater than VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x77
          cpu.registers[0x1] = 0xA
          cpu.registers[0x7] = 0xB
          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'set VF to 0x1 if VY is equal VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x77
          cpu.registers[0x1] = 0xC
          cpu.registers[0x7] = 0xC
          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'store only the lowest 8 bits of the result in VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0x84
          cpu.memory[0x201] = 0x27
          cpu.registers[0x4] = 0xAA
          cpu.registers[0x2] = 0xFEE
          cpu.cycle

          cpu.registers[0x4].must_equal(0x44)
        end
      end

      describe 'instruction 0x8XYE' do
        it 'set VF to 0x1 if the most-significant bit of VX is 1' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x6E
          cpu.registers[0x1] = 0x80
          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'set VF to 0x0 if the most-significant bit of VX is 0' do
          cpu.memory = []
          cpu.memory[0x200] = 0x81
          cpu.memory[0x201] = 0x6E
          cpu.registers[0x1] = 0x50
          cpu.cycle

          cpu.registers[0xF].must_equal(0x0)
        end

        it 'shifts VX left by one' do
          cpu.memory = []
          cpu.memory[0x200] = 0x84
          cpu.memory[0x201] = 0x5E
          cpu.registers[0x4] = 0x3
          cpu.cycle

          cpu.registers[0x4].must_equal(0x6)
        end
      end

      describe 'instruction 0x9XY0' do
        it 'skip next instruction if VX is not equal VY' do
          cpu.memory = []
          cpu.memory[0x200] = 0x95
          cpu.memory[0x201] = 0x10
          cpu.registers[0x5] = 0x12
          cpu.registers[0x1] = 0xA
          cpu.cycle

          cpu.pc.must_equal(0x202)
        end

        it 'not skip next instruction if VX is equal VY' do
          cpu.memory = []
          cpu.memory[0x200] = 0x95
          cpu.memory[0x201] = 0x10
          cpu.registers[0x5] = 0x12
          cpu.registers[0x1] = 0x12
          cpu.cycle

          cpu.pc.must_equal(0x200)
        end
      end

      describe 'instruction 0xANNN' do
        it 'set register I to NNN value' do
          cpu.memory = []
          cpu.memory[0x200] = 0xA9
          cpu.memory[0x201] = 0x25
          cpu.cycle

          cpu.i.must_equal(0x925)
        end
      end

      describe 'instruction 0xBNNN' do
        it 'jump to location NNN + V0' do
          cpu.memory = []
          cpu.memory[0x200] = 0xB1
          cpu.memory[0x201] = 0x32
          cpu.registers[0x0] = 0xB
          cpu.cycle

          cpu.pc.must_equal(0x13D)
        end
      end

      describe 'instruction 0xCXNN' do
        it 'sets VX to an random number AND NN'
      end

      describe 'instruction 0xDXYN' do
        it 'detect pixel collision in first byte of the sprite' do
          cpu.memory = []
          cpu.memory[0x200] = 0xD4
          cpu.memory[0x201] = 0x71
          cpu.i = 0xA

          cpu.memory[cpu.i] = 0b11010001

          cpu.vram[:sprite][0] = 0b10000

          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'detect pixel collision in the middle byte of the sprite' do
          cpu.memory = []
          cpu.memory[0x200] = 0xD4
          cpu.memory[0x201] = 0x74
          cpu.i = 0xA

          cpu.memory[cpu.i]     = 0b11010001
          cpu.memory[cpu.i + 1] = 0b10001
          cpu.memory[cpu.i + 2] = 0b11010001
          cpu.memory[cpu.i + 3] = 0b11010001

          cpu.vram[:sprite][0] = 0b0
          cpu.vram[:sprite][1] = 0b1011
          cpu.vram[:sprite][2] = 0b0
          cpu.vram[:sprite][3] = 0b0

          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'detect pixel collision in the last byte of the sprite' do
          cpu.memory = []
          cpu.memory[0x200] = 0xD4
          cpu.memory[0x201] = 0x74
          cpu.i = 0xA

          cpu.memory[cpu.i]     = 0b11010001
          cpu.memory[cpu.i + 1] = 0b11010001
          cpu.memory[cpu.i + 2] = 0b11010001
          cpu.memory[cpu.i + 3] = 0b11010001

          cpu.vram[:sprite][0] = 0b0
          cpu.vram[:sprite][1] = 0b0
          cpu.vram[:sprite][2] = 0b0
          cpu.vram[:sprite][3] = 0b11000

          cpu.cycle

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'apply XOR bit operation properly without pixel collision' do
          cpu.memory = []
          cpu.memory[0x200] = 0xD1
          cpu.memory[0x201] = 0x15
          cpu.i = 0xA
          cpu.memory[cpu.i]     = 0xF0
          cpu.memory[cpu.i + 1] = 0x80
          cpu.memory[cpu.i + 2] = 0x80
          cpu.memory[cpu.i + 3] = 0x80
          cpu.memory[cpu.i + 4] = 0xF0

          cpu.cycle

          (0..4).each do |num|
            cpu.vram[:sprite][num].must_equal(cpu.memory[cpu.i + num])
          end
          cpu.registers[0xF].must_equal(0x0)
        end

        it 'apply XOR bit operation properly with pixel collision' do
          cpu.memory = []
          cpu.memory[0x200] = 0xD4
          cpu.memory[0x201] = 0x65
          cpu.i = 0xA

          cpu.memory[cpu.i]     = 0b11010001
          cpu.memory[cpu.i + 1] = 0b10000011
          cpu.memory[cpu.i + 2] = 0b00110011
          cpu.memory[cpu.i + 3] = 0b10000001
          cpu.memory[cpu.i + 4] = 0b11100010

          cpu.vram[:sprite][0] = 0b10001011
          cpu.vram[:sprite][1] = 0b10001
          cpu.vram[:sprite][2] = 0b111001
          cpu.vram[:sprite][3] = 0b11111111
          cpu.vram[:sprite][4] = 0b11001100

          cpu.cycle

          cpu.vram[:sprite][0].must_equal(0b1011010)
          cpu.vram[:sprite][1].must_equal(0b10010010)
          cpu.vram[:sprite][2].must_equal(0b1010)
          cpu.vram[:sprite][3].must_equal(0b1111110)
          cpu.vram[:sprite][4].must_equal(0b101110)

          cpu.registers[0xF].must_equal(0x1)
        end

        it 'clear vram if same sprite is sent to vram' do
          cpu.memory = []
          cpu.memory[0x200] = 0xD1
          cpu.memory[0x201] = 0x15
          cpu.i = 0xA

          cpu.memory[cpu.i]     = 0xF0
          cpu.memory[cpu.i + 1] = 0x80
          cpu.memory[cpu.i + 2] = 0x80
          cpu.memory[cpu.i + 3] = 0x80
          cpu.memory[cpu.i + 4] = 0xF0

          cpu.vram[:sprite][0] = 0xF0
          cpu.vram[:sprite][1] = 0x80
          cpu.vram[:sprite][2] = 0x80
          cpu.vram[:sprite][3] = 0x80
          cpu.vram[:sprite][4] = 0xF0

          cpu.cycle

          (0..4).each do |num|
            cpu.vram[:sprite][num].must_equal(0x0)
          end
          cpu.registers[0xF].must_equal(0x1)
        end
      end

      describe 'instruction 0xEX9E' do
        it 'skip next instruction if key with the value of Vx is pressed'
      end

      describe 'instruction 0xEXA1' do
        it 'skip next instruction if key with the value of Vx is not pressed'
      end

      describe 'instruction 0xFX07' do
        it 'store the value of the delay timer in register VX.' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF1
          cpu.memory[0x201] = 0x07
          cpu.dt = 0xA
          cpu.cycle

          cpu.registers[0x1].must_equal(0xA)
        end
      end

      describe 'instruction 0xFX0A' do
        it ''
      end

      describe 'instruction 0xFX15' do
        it 'set delay timer to the value of register VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF3
          cpu.memory[0x201] = 0x15
          cpu.registers[0x3] = 0xC
          cpu.cycle

          cpu.dt.must_equal(0xC)
        end
      end

      describe 'instruction 0xFX18' do
        it 'set sound timer to the value of register VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF2
          cpu.memory[0x201] = 0x18
          cpu.registers[0x2] = 0x5
          cpu.cycle

          cpu.st.must_equal(0x5)
        end
      end

      describe 'instruction 0xFX1E' do
        it 'adds VX to I' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF7
          cpu.memory[0x201] = 0x1E
          cpu.registers[0x7] = 0x5
          cpu.i = 0x2
          cpu.cycle

          cpu.i.must_equal(0x7)
        end
      end

      describe 'instruction 0xFX29' do
        it 'sets I to the location of the sprite in VX' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF3
          cpu.memory[0x201] = 0x29
          cpu.registers[0x3] = 0x5
          cpu.cycle

          cpu.i.must_equal(0x19)
        end
      end

      # TODO Needs improvement on these tests description
      describe 'instruction 0xFX33' do
        it 'store BCD digit at I' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF4
          cpu.memory[0x201] = 0x33
          cpu.i = 0x1
          cpu.registers[0x4] = 0xAAC
          cpu.cycle

          cpu.memory[0x1].must_equal(0x1B)
        end

        it 'store BCD digit at I + 1' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF4
          cpu.memory[0x201] = 0x33
          cpu.i = 0x1
          cpu.registers[0x4] = 0xAAC
          cpu.cycle

          cpu.memory[0x2].must_equal(0x3)
        end

        it 'store BCD digit at I + 2' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF4
          cpu.memory[0x201] = 0x33
          cpu.i = 0x1
          cpu.registers[0x4] = 0xAAC
          cpu.cycle

          cpu.memory[0x3].must_equal(0x2)
        end
      end

      describe 'instruction 0xFX55' do
        it 'store registers V0 through VX in memory starting at location I' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF3
          cpu.memory[0x201] = 0x55
          cpu.i = 0x1
          cpu.registers[0x0] = 0xA
          cpu.registers[0x1] = 0xB
          cpu.registers[0x2] = 0xC
          cpu.registers[0x3] = 0xD
          cpu.cycle

          (0..3).each do |r|
            cpu.memory[cpu.i + r].must_equal(cpu.registers[r])
          end
        end
      end

      describe 'instruction 0xFX65' do
        it 'read registers V0 through VX from memory starting at location I' do
          cpu.memory = []
          cpu.memory[0x200] = 0xF3
          cpu.memory[0x201] = 0x65
          cpu.i = 0x1
          cpu.memory[0x1] = 0xA
          cpu.memory[0x2] = 0xB
          cpu.memory[0x3] = 0xC
          cpu.memory[0x4] = 0xD
          cpu.cycle

          (0..3).each do |r|
            cpu.registers[r].must_equal(cpu.memory[cpu.i + r])
          end
        end
      end

    end
  end
end
