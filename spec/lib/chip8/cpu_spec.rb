require 'spec_helper'

describe Chip8::CPU do
  let(:cpu) { Chip8::CPU.new }

  it 'is composed by registers' do
    cpu.should respond_to :registers
  end

  context 'PC - program counter' do
    it 'starts at position 0x200' do
      cpu.pc.should eq(0x200)
    end
  end

  describe '#cycle' do
    before do
      cpu.memory = []
      cpu.memory[0x200] = 0x12
      cpu.memory[0x201] = 0x25
    end

    context 'fetch opcode' do
      it 'set @opcode reading values from memory' do
        expected_opcode = 0x1225
        cpu.cycle
        cpu.instance_variable_get(:@opcode).should eq(expected_opcode)
      end
    end

    context 'decode opcode' do
      it 'set the lowest 12 bits of the opcode to @nnn' do
        expected_address = 0x225
        cpu.cycle
        cpu.instance_variable_get(:@nnn).should eq(expected_address)
      end

      it 'set the lowest 8 bits of the opcode to @nn' do
        expected_byte = 0x25
        cpu.cycle
        cpu.instance_variable_get(:@nn).should eq(expected_byte)
      end

      it 'set the lowest 4 bits of the opcode to @n' do
        expected_nibble = 0x5
        cpu.cycle
        cpu.instance_variable_get(:@n).should eq(expected_nibble)
      end

      it 'set the lower 4 bits of the high opcode byte to register X' do
        expected_x = 0x2
        cpu.cycle
        cpu.instance_variable_get(:@x).should eq(expected_x)
      end

      it 'set the upper 4 bits of the low opcode byte to register Y' do
        expected_y = 0x2
        cpu.cycle
        cpu.instance_variable_get(:@y).should eq(expected_y)
      end
    end

    context 'execute opcode' do
      describe '0x1' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x14
          cpu.memory[0x201] = 0x21
        end

        it_should 'set Program Counter value', 0x421
      end

      describe '0x2' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x22
          cpu.memory[0x201] = 0x31
        end

        it_should 'push Program Counter value to Stack'
        it_should 'set Program Counter value', 0x231
      end

      describe '0x3' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x32
          cpu.memory[0x201] = 0x31

          cpu.instance_variable_set(:@x, 2)
          cpu.registers[cpu.instance_variable_get(:@x)] = 49
        end

        it_should 'set Program Counter value', 0x202
      end

      describe '0x4' do
        before do
          cpu.memory = []
          cpu.memory[0x200] = 0x42
          cpu.memory[0x201] = 0x31

          cpu.instance_variable_set(:@x, 2)
          cpu.registers[cpu.instance_variable_get(:@x)] = 50
        end

        it_should 'set Program Counter value', 0x202
      end
    end

  end
end
