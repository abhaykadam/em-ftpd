Then /^I wait for response as "([^"]*)"$/ do |expected|
  Timeout::timeout(exit_timeout) do
    loop do
      break if assert_partial_output_interactive(expected)
      sleep 0.1
    end
  end
end
