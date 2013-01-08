@announce
@download
Feature: User Login

	Scenario: Registered User Login
		When I run `ftp localhost` interactively
		And I type "test1"
		And I type "1234"
		Then I wait for response as "230 OK, password correct"
		When I type "GET passwd"
		Then the output should contain:
			"""
			227 Entering Passive Mode (127,0,0,1,179,224)
150 Data transfer starting 26 bytes
			"""
