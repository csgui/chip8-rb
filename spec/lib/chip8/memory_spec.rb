require 'spec_helper'

describe Chip8::Memory do
  let(:memory) { Chip8::Memory.new }
  let(:rom)    { rom_path :invaders }

  it 'should have a page size of 4KB' do
    memory.instance_variable_get(:@page).size.should be_equal 4096
  end

  it 'should be initialized with 0x0' do
    memory.instance_variable_get(:@page).collect do |byte|
      byte == 0x0
    end.any?.should be_true
  end

  describe '#load' do
    it 'loading the ROM starting at location 0x200' do
      memory.load(rom)
      memory[0x200].should_not be_equal 0x0
    end
  end

  describe '#[]' do
    it 'returns a memory address value' do
      memory[0x200].should be_equal 0x0
    end
  end

end
