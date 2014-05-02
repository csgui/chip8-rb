require 'gosu'
require 'texplay'

module VDP

  WIDTH = 64
  HEIGHT = 32
  SCALE = 10

  class EmptyImageStub
    def initialize(w, h)
      @w, @h = w, h
    end

    def to_blob
      "\0" * @w * @h * 4
    end

    def rows
      @h
    end

    def columns
      @w
    end
  end

  class Display < Gosu::Window
    def initialize
      super(640, 320, false, 1)
      stub = EmptyImageStub.new(WIDTH * SCALE, HEIGHT * SCALE)
      @canvas = Gosu::Image.new(self, stub, false)
      self.caption = "Emul8 - Ruby Chip8 Emulator"
      @clear = false
    end
  end
end
