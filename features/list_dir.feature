@announce
Feature: List a Directory

	Scenario: List a available directory
		Given a ftp-client starts and connects with server
		And I have logged in typing "USER test1" followed by "PASS 1234"
		When I enter the LIST command "LIST test_ls"
		Then the server responds with:
			"""
			150 Opening ASCII mode data connection for file list
drwxrwxrwx 1 owner  group            0 Jan 08 12:51 x_dir
-rwxrwxrwx 1 owner  group            0 Jan 08 12:35 test_ls
-rwxrwxrwx 1 owner  group           25 Jan 08 12:38 hello.txt
-rwxrwxrwx 1 owner  group          319 Jan 08 12:38 server.rb
226 Closing data connection, sent 246 bytes
			"""

	Scenario: Listing a non-available directory
		Given a ftp-client starts and connects with server
		And I have logged in typing "USER test1" followed by "PASS 1234"
		When I enter the LIST command "LIST not_avail"
		Then the server responds with:
			"""
			227 Entering Passive Mode (127,0,0,1,183,59)
150 Opening ASCII mode data connection for file list

551 directory not available
			"""
