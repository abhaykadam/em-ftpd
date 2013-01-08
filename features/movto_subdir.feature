@announce
@subdir
Feature: Move to a sub-directory

	Scenario: Move to a sub-directory
		When I run `telnet localhost 21` interactively
		And I type "USER test1"
		Then I wait for response as "331 OK, password required"
		When I type "PASS 1234"
		Then I wait for response as "230 OK, password correct"
		When I type "LIST test_ls"
		Then I wait for response as "250 Directory changed to /test_ls"
