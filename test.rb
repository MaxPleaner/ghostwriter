# initialize, define_step, invoke_step
g = Ghostwriter.new

g.define_step(/test args is a single string with input: (.*)/) do |args|
  args_class_ok = g.expectation { expect(args.is_a?(String)).to eq(true) }
  g.expectation_result([:args_class_ok, args_class_ok, args.class])
end

["", "foo", "foo bar"].each do |input|
  cmd = "test args is a single string with input: #{input}"
  result = g.invoke_step!(cmd)
end
