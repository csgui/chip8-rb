lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH << lib

require 'minitest/autorun'
require 'minitest/reporters'

MiniTest::Reporters.use!

def rom_path(name)
  "test/fixtures/files/#{name}.rom"
end
