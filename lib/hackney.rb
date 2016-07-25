require 'cucumber'
require 'rspec'
require 'colored'

class AmbiguousStepError < StandardError; end
class NoMatchingStepError < StandardError; end

class Hackney

  InstanceMethodDocs = [
    "DEFINE A STEP: define_step(regex, &blk)",
    "INVOKE A STEP: invoke_step(string)",
    "CALL RSPEC FROM A STEP: expectation(blk)",
    "RETURN FROM STEP: expectation_result(name, result_bool, actual_result)"
  ]

  # start out by initializing Hackney
  def initialize
    runtime = Cucumber::Runtime.new
    config = Cucumber::Configuration.new
    language = Cucumber::RbSupport::RbLanguage.new(runtime, config)
    @dsl = Cucumber::RbSupport::RbDsl
    @dsl.rb_language = language
    @instance_method_docs = InstanceMethodDocs
    @steps = {}
  end

  # this will setup @dsl and @steps attributes
  attr_reader :dsl, :steps

  # dynamically define a step using a regex and a block
  # the block will receive one argument, an array containing the results of the regex's match groups
  # for example, /foo (.+)/, if called like "foo bar asd", will pass ["bar asd"] to the block. 
  def define_step(regex, &blk)
    steps[regex] = dsl.register_rb_step_definition(regex, blk)
  end

  # call invoke_step and print output
  def invoke_step!(string)
    result = invoke_step(string)
    puts "#{string}\n#{result}\n\n"
  end

  # provide a string which is parsed using the steps' regexes and invoked
  def invoke_step(string)
    matches = steps.keys.select { |regex| string =~ regex }
    raise(AmbiguousStepError, "multiple matching steps for string #{string}: #{matches}") if matches.length > 1
    raise(NoMatchingStepError, "no matchiing step for string #{string}") if matches.empty?
    matching_regex = matches[0]
    regex_results = matching_regex.match(string).to_a
    full_match_string, arguments = regex_results.shift, regex_results
    steps[matching_regex].invoke(arguments)
  end

  def expectation_result(*result_sets)
    result_sets.map do |array|
      name, status, true_result = array.shift(3)
      "#{name } ? " + (status ? "true".green : "#{"false".red} - #{true_result}")
    end.join("\n")
  end

  # expose the rspec 'expect' method
  # creates and runs an anonymous rspec expectation
  # Usage example: Hackney.new.expectation { expect(1).to eq(2) } 
                   # => returns false because 1 != 2
  def expectation(&blk)
    RSpec.describe("") { it("") { instance_exec(&blk) } }.run
  end

end


