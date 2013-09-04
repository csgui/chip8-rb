#!/usr/bin/env ruby

require 'chip8'

class Emulator
  def initialize
    @cpu = Chip8::CPU.new
  end

  def start(rom)
    @cpu.memory.load(rom)
    @cpu.run
  end

end

Emulator.new.start(ARGV[0])
