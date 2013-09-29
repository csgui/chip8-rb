module Chip8
  class Emulator
    def self.run(rom, ui)
      bytecode = File.open(rom, 'rb') { |f| f.read }.unpack('C*')
      memory = Chip8::Memory.new
      memory.load(bytecode)
      memory.ui = ui

      cpu = Chip8::CPU.new
      cpu.memory = memory

      Thread.new do
        cpu.emulate
      end

      memory.ui.show
    end
  end
end
