require 'gosu'
require 'texplay'

module Chip8

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

  class VDP < Gosu::Window
    attr_accessor :vram, :keyboard

    WIDTH = 64
    HEIGHT = 32
    SCALE = 10

    def initialize
      super(640, 320, false, 1)
      stub = EmptyImageStub.new(WIDTH * SCALE, HEIGHT * SCALE)
      @canvas = Gosu::Image.new(self, stub, false)
      self.caption = "Chip8-rb"
      @vram = Array.new(WIDTH * HEIGHT, 0x0)
      @keyboard = Array.new
    end

    def get_pixel(x, y)
      vram[y * 64 + x]
    end

    def set_pixel(x, y, value)
      vram[y * 64 + x] = value
    end

    def update
      video = vram

      @canvas.paint do
        (0..32).each do |i|
          (0..64).each do |j|
            color = video[i * 64 + j] == 1 ? :white : :black
            rect(j * SCALE, i * SCALE, (j + 1) * SCALE, (i + 1) * SCALE, :color => color, :fill => true)
          end
        end
      end
    end

    def draw
      @canvas.draw(0, 0, 1)
    end

    def button_down(id)
      case id
      when Gosu::Kb1
        keyboard[0x1] = 1
      when Gosu::Kb2
        keyboard[0x2] = 1
      when Gosu::Kb3
        keyboard[0x3] = 1
      when Gosu::Kb4
        keyboard[0xC] = 1
      when Gosu::KbQ
        keyboard[0x4] = 1
      when Gosu::KbW
        keyboard[0x5] = 1
      when Gosu::KbE
        keyboard[0x6] = 1
      when Gosu::KbR
        keyboard[0xD] = 1
      when Gosu::KbA
        keyboard[0x7] = 1
      when Gosu::KbS
        keyboard[0x8] = 1
      when Gosu::KbD
        keyboard[0x9] = 1
      when Gosu::KbF
        keyboard[0xE] = 1
      when Gosu::KbZ
        keyboard[0xA] = 1
      when Gosu::KbX
        keyboard[0x0] = 1
      when Gosu::KbC
        keyboard[0xB] = 1
      when Gosu::KbV
        keyboard[0xF] = 1
      end
    end

     def button_up(id)
      case id
      when Gosu::Kb1
        keyboard[0x1] = 0
      when Gosu::Kb2
        keyboard[0x2] = 0
      when Gosu::Kb3
        keyboard[0x3] = 0
      when Gosu::Kb4
        keyboard[0xC] = 0
      when Gosu::KbQ
        keyboard[0x4] = 0
      when Gosu::KbW
        keyboard[0x5] = 0
      when Gosu::KbE
        keyboard[0x6] = 0
      when Gosu::KbR
        keyboard[0xD] = 0
      when Gosu::KbA
        keyboard[0x7] = 0
      when Gosu::KbS
        keyboard[0x8] = 0
      when Gosu::KbD
        keyboard[0x9] = 0
      when Gosu::KbF
        keyboard[0xE] = 0
      when Gosu::KbZ
        keyboard[0xA] = 0
      when Gosu::KbX
        keyboard[0x0] = 0
      when Gosu::KbC
        keyboard[0xB] = 0
      when Gosu::KbV
        keyboard[0xF] = 0
      end
    end

  end
end
