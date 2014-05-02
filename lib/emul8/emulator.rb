module Emul8
  class Emulator
    def self.run(rom, vdp)
      bytecode = File.open(rom, 'rb') { |f| f.read }.unpack('C*')

      memory = Emul8::Memory.new
      memory.vdp = vdp
      memory.load bytecode

      Emul8::MemoryBus.new(cpu, memory)

      loop do
        cpu.emulate
      end
    end
  end

  class MemoryBus
    include Memory

    def initialize(cpu, memory)
      @memory = memory
    end
  end

end

class CPU
  attr_accessor :memory

  def initialize
    @memory = MemoryBus.new
  end

  def emulate
    memory.next
  end
end
