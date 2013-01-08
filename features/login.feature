@announce
Feature: User Login

	Scenario: Registered User Login
		Given I run `telnet localhost 21` interactively
		When I type "USER test1"
		Then the output should contain "331 OK, password required"
		When I enter the PASS command "PASS 1234"
		Then the response would be "230 OK, password correct"

	Scenario: Unregistered User Login
		Given a ftp-client starts and connects with server
		When I enter the USER command "USER test11"
		Then the server responds with "331 OK, password required"
		When I enter the PASS command "PASS 1234"
		Then the response would be "530 incorrect login. not logged in."

	Scenario: User Re-login
		Given a ftp-client starts and connects with server
		And I have logged in typing "USER test1" followed by "PASS 1234"
		When I enter the USER command "USER test1"
		Then the server responds with "500 Already logged in"
