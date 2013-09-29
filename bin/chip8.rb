#!/usr/bin/env ruby

require 'chip8'

Chip8::Emulator.run(ARGV[0], Chip8::Display.new)
