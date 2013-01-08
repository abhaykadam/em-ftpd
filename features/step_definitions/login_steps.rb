Given /^a ftp\-client starts and connects with server$/ do 
	run_interactive unescape('telnet localhost 21')
end	

When /^I enter the USER command "(.*?)"$/ do |user_cmd|
	type user_cmd
end

Then /^the server responds with "(.*?)"$/ do |response|
	assert_partial_output_interactive response
end

When /^I enter the PASS command "(.*?)"$/ do |pass_cmd|
	type pass_cmd
end

Then /^the response would be "(.*?)"$/ do |response|
	assert_partial_output_interactive response
end

Given /^I have logged in typing "(.*?)" followed by "(.*?)"$/ do |user_cmd, pass_cmd|
	type user_cmd
	type pass_cmd
end
