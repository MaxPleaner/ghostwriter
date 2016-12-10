## I'm keeping this repo for reference purposes but I probably wouldn't reach for this gem. Rather, take a look at [gemmy](http://github.com/gemmy) which basically has the same functionality in it's DynamicSteps feature.

## This project is probably a little overengineered

Cucumber and Rspec are a great combination for testing. Rspec provides all the matchers and
cucumber has a nice system for organizing them. The human-readable element of cucumber is marvelous.

The problem is that cucumber doesn't make it easy to run tests without using the `cucumber` shell command.
I wanted to define and run steps dynamically from any ruby script. To get this to work, I looked into the
[cucumber-ruby rubydoc](http://www.rubydoc.info/github/cucumber/cucumber-ruby/) and tried to use the existing API
as much as possible. I still ended up building some custom components. I think the following could potentially be refactored to use
cucumber's existing API, but I have written my own components for this gem:

- create steps on-the-fly
- invoke steps by running a string through a regex matcher
- use rspec in the steps
- pretty print output



### How to use

The source for a `Hackney` module is in [hackney.rb](./lib/hackney.rb).
Some example usage code can be seen in [test.rb](./test.rb), and is pasted below:

```ruby
require_relative("./lib/hackney.rb")
runner = Hackney.new
runner.define_step(/When input is (.*), test that the argument passed to the block is a string/) do |args|
  args_class_ok = runner.expectation { expect(args.is_a?(String)).to eq(true) }
  runner.expectation_result([:args_class_ok, args_class_ok, args.class])
end
runner.invoke_step! "When input is , test that the argument passed to the block is a string"
runner.invoke_step! "When input is foo, test that the argument passed to the block is a string"
runner.invoke_step! "When input is foobar, test that the argument passed to the block is a string"

```

This produces the following console output (with a little red/green coloring):

```txt
When input is , test that the argument passed to the block is a string
args_class_ok ? true

When input is foo, test that the argument passed to the block is a string
args_class_ok ? true

When input is foobar, test that the argument passed to the block is a string
args_class_ok ? true
```

There are few instance methods on `Hackney` that this uses:

- `#define_step(regex, &block)` to define a step
- `#expectation(&blk)` to use rspec's `expect` method inside a step.
- `#expectation_result([test_case_name, result_boolean, actual_result])` is what a step should return. Any number of length-3 arrays can be 
provided as subsequent arguments if a step contains multiple expectations.
- `#invoke_step!(string_command)` will find matching steps for the string, run them, and print the output. Note that `invoke_step` without 
the exclamation point does the same thing without printing any output. 

The `test.rb`. can be run with `ruby`. There is no special shell command that needs to be run. 
