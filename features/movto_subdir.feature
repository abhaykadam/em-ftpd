@announce
Feature: Move to a sub-directory

	Scenario: Move to a sub-directory
		Given a ftp-client starts and connects with server
		And I have logged in typing "USER test1" followed by "PASS 1234"
		When I enter the LIST command "LIST test_ls"
		Then the server responds with "250 Directory changed to /test_ls"
