require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'vcr_cassettes'
  c.hook_into :fakeweb
end

VCR.cucumber_tags do |t|
	t.tag	'@login'
end
