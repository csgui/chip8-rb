require 'chip8'
require 'support/shared_examples_for_cpu.rb'

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  c.alias_it_should_behave_like_to :it_should, 'should'
end

def hex_word(word)
  sprintf("$%04X", word) rescue "$????"
end

def rom_path(name)
  "spec/fixtures/files/#{name}.rom"
end
