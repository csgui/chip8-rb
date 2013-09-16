require 'spec_helper'

describe Chip8::CPU do
  let(:cpu) { Chip8::CPU.new }
  let(:rom) { rom_path :invaders }

  it 'is composed by registers' do
    cpu.should respond_to :registers
  end

  context 'PC - program counter' do
    it 'starts at position 0x200' do
      cpu.pc.should be_equal 0x200
    end
  end

  describe '#cycle' do
    before do
      memory = Chip8::Memory.new
      memory.load(rom)
      cpu.memory = memory
    end

    context 'fetch opcode' do
      it 'retrieve opcode from memory PC location' do
        cpu.cycle
        cpu.instance_variable_get(:@opcode).should be_equal 0x1225
      end
    end

    context 'decode opcode' do

    end

    context 'execute opcode' do
      describe '0x1' do
        it_should 'set PC value', 0x225
      end

      describe '0x2' do

      end
    end

  end
end
