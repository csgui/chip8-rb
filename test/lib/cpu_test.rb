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

    end
  end
end
