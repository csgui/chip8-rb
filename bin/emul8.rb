#!/usr/bin/env ruby

lib = File.expand_path('../../lib', __FILE__)
$:.unshift lib

require 'emul8'
require 'vdp'

Emul8::Emulator.run(ARGV[0], VDP::Display.new)
