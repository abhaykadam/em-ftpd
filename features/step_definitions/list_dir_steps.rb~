When /^I enter the LIST command "(.*?)"$/ do |list_cmd|
	type list_cmd
end

Then /^the server responds with:$/ do |listing|
	assert_partial_output_interactive listing
end

