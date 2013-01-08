@announce
@upload
Feature: User Login

	Scenario: Registered User Login
		When I run `ftp localhost` interactively
		And I type "test1"
		And I type "1234"
		Then I wait for response as "230 OK, password correct"
		When I type "SEND test_file.txt /test_ls/test_file.txt"
		Then the output should contain:
			"""
			227 Entering Passive Mode (127,0,0,1,136,85)
150 Data transfer starting
226 OK, received 0 bytes
40 bytes sen
			"""
