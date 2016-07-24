require_relative("./ghostwriter.rb")

g = Ghostwriter.new

g.define_step(/When input is (.*), test that the argument passed to the block is a string/) do |args|
  args_class_ok = g.expectation { expect(args.is_a?(String)).to eq(true) }
  g.expectation_result([:args_class_ok, args_class_ok, args.class])
end

["", "foo", "foo bar"].each do |input|
  cmd = "When input is #{input}, test that the argument passed to the block is a string"
  result = g.invoke_step!(cmd)
end
