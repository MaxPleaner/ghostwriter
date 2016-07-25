require_relative("./lib/hackney.rb")

runner = Hackney.new

runner.define_step(/When input is (.*), test that the argument passed to the block is a string/) do |args|
  args_class_ok = runner.expectation { expect(args.is_a?(String)).to eq(true) }
  runner.expectation_result([:args_class_ok, args_class_ok, args.class])
end

runner.invoke_step! "When input is , test that the argument passed to the block is a string"
runner.invoke_step! "When input is foo, test that the argument passed to the block is a string"
runner.invoke_step! "When input is foobar, test that the argument passed to the block is a string"
