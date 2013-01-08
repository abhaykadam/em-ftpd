@announce
@listing
Feature: List a Directory

	Scenario: List a available directory
		When I run `telnet localhost 21` interactively
		And I type "USER test1"
		Then I wait for response as "331 OK, password required"
		When I type "PASS 1234"
		Then I wait for response as "230 OK, password correct"
		When I type "LIST test_ls"
		Then the output should contain:
			"""
			150 Opening ASCII mode data connection for file list
drwxrwxrwx 1 owner  group            0 Jan 08 12:51 x_dir
-rwxrwxrwx 1 owner  group            0 Jan 08 12:35 test_ls
-rwxrwxrwx 1 owner  group           25 Jan 08 12:38 hello.txt
-rwxrwxrwx 1 owner  group          319 Jan 08 12:38 server.rb
226 Closing data connection, sent 246 bytes
			"""

	Scenario: Listing a non-available directory
		When I run `telnet localhost 21` interactively
		And I type "USER test1"
		Then I wait for response as "331 OK, password required"
		When I type "PASS 1234"
		Then I wait for response as "230 OK, password correct"
		When I type "LIST not_avail"
		Then the output should contain:
			"""
			227 Entering Passive Mode (127,0,0,1,183,59)
150 Opening ASCII mode data connection for file list

551 directory not available
			"""
