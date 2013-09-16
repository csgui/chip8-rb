#!/usr/bin/env ruby

require 'chip8'

module Chip8
  def self.start(rom)
    emulator = Emulator.new
    emulator.load(rom)
    emulator.run
  end

  class Emulator
    def load(rom)
      @memory = Chip8::Memory.new
      @memory.load(rom)
    end

    def run
      cpu = Chip8::CPU.new
      cpu.memory = @memory
      cpu.emulate
    end
  end
end

Chip8.start(ARGV[0])
