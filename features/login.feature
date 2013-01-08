@announce
@login
Feature: User Login

	Scenario: Registered User Login
		When I run `telnet localhost 21` interactively
		And I type "USER test1"
		Then I wait for response as "331 OK, password required"
		And I type "PASS 1234"
		Then I wait for response as "230 OK, password correct"

	Scenario: Unregistered User Login
		When I run `telnet localhost 21` interactively
		And I type "USER test11"
		Then I wait for response as "331 OK, password required"
		When I type "PASS 1234"
		Then I wait for response as "530 incorrect login. not logged in."

	Scenario: User Re-login
		When I run `telnet localhost 21` interactively
		And I type "USER test1"
		Then I wait for response as "331 OK, password required"
		When I type "PASS 1234"
		Then I wait for response as "230 OK, password correct"
		When I type "USER test1"
		Then I wait for response as "500 Already logged in"
