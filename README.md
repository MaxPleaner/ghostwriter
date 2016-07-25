### What is it?

Cucumber and Rspec are a great combination for testing. Rspec provides all the matchers and
cucumber has a nice system for organizing them. The human-readable element of cucumber is marvelous.

The problem is that cucumber doesn't make it easy to run tests without using the `cucumber` shell command.
I wanted to define and run steps dynamically from any ruby script. To get this to work, I looked into the
[cucumber-ruby rubydoc](http://www.rubydoc.info/github/cucumber/cucumber-ruby/) and tried to use the existing API
as much as possible. I still ended up building some custom components. I think the following could be refactored to use
cucumber's existing API, and I'd be interested if anyone knows how to do the following without using the cucumber shell command:

- create steps on-the-fly
- invoke steps by running a string through a regex matcher
- use rspec in the steps
- use existing cli formatter


### How to use

The source for a `Hackney` module is in [hackney.rb](./lib/hackney.rb).

It's been packaged up into a gem, so just `gem install hackney` or put `gem 'hackney'` in a Gemfile.

Some example usage code can be seen in [test.rb](./test.rb), and is pasted below for convenience:

```ruby
require_relative("./lib/hackney.rb")
# if the 'hackey' gem is installed, require('hackney') should be used instead

g = Ghostwriter.new

g.define_step(/When input is (.*), test that the argument passed to the block is a string/) do |args|
  args_class_ok = g.expectation { expect(args.is_a?(String)).to eq(true) }
  g.expectation_result([:args_class_ok, args_class_ok, args.class])
end

["", "foo", "foo bar"].each do |input|
  cmd = "When input is #{input}, test that the argument passed to the block is a string"
  result = g.invoke_step!(cmd)
end
```

There are few components in this to understand:

- `Ghostwriter#define_step(regex, &block)` to define a step
- `Ghostwriter#expectation(&blk)` to use rspec's `expect` method inside a step.
- `Ghostwriter#expectation_result(test_case_name, result_boolean, actual_result)` is what a step should return
- `Ghostwriter#invoke_step!(string_command)` will find matching steps for the string, run them, and print the output

The `test.rb`. can be run with `ruby`. There is no special shell command that needs to be run. 
