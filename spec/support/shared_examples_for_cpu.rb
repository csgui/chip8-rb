shared_examples_for 'set PC value' do |expected|
  it do
    cpu.cycle

    value = cpu.pc
    value.should be(expected), "Expected: #{hex_word(expected)}, found: #{hex_word(value)}"
  end
end
