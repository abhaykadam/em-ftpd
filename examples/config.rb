require 'em-ftpd'
require File.dirname(__FILE__) + "/examples/driver.rb"

AWS_KEY    = 'place your aws key here'
AWS_SECRET = 'place your aws secrete key here'
AWS_BUCKET = 'place your aws bucket name here'

driver      Driver
driver_args AWS_KEY, AWS_SECRET, AWS_BUCKET
