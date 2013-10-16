module Chip8
  class Emulator
    def self.run(rom)
      bytecode = File.open(rom, 'rb') { |f| f.read }.unpack('C*')
      memory = Chip8::Memory.new
      memory.load(bytecode)

      cpu = Chip8::CPU.new
      cpu.memory = memory
      cpu.vdp = Chip8::VDP.new
      Thread.new do
        cpu.emulate
      end
      cpu.vdp.show
    end
  end
end
