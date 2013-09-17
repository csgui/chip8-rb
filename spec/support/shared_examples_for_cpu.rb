#
shared_examples_for 'set Program Counter value' do |expected|
  it do
    cpu.cycle

    value = cpu.pc
    value.should eq(expected), "Expected: #{hex_word(expected)}, found: #{hex_word(value)}"
  end
end

#
shared_examples_for 'push Program Counter value to Stack' do
  it do
    pc_before_cycle = cpu.pc
    cpu.cycle
    cpu.stack.last.should eq(pc_before_cycle)
  end
end
