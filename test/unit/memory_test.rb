require File.expand_path('../../test_helper', __FILE__)
require 'chip8/memory'

describe Chip8::Memory do

  let(:memory) { Chip8::Memory.new }
  let(:rom) { rom_path :invaders }

  it 'should have a page size of 4KB' do
    memory.instance_variable_get(:@page).size.must_equal 4096
  end

  it 'should be initialized with 0x0' do
    memory.instance_variable_get(:@page).collect do |byte|
      byte == 0x0
    end.any?.must_equal true
  end

  describe '#load' do
    it 'the first ROM byte should be at location 0x200' do
      memory.load(rom)
      memory[0x200].wont_equal 0x0
    end
  end

end
