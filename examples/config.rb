require 'em-ftpd'
require File.dirname(__FILE__) + "/examples/driver.rb"

AWS_KEY    = 'AKIAJ2IGHZQHCSJYT22A'
AWS_SECRET = 'etpwFn9XnqWrfYKwrr2++++hgmEBFMxCvuBus/Xy'
AWS_BUCKET = 'em-ftpd-trial-assignment1/abhay'

driver      Driver
driver_args AWS_KEY, AWS_SECRET, AWS_BUCKET