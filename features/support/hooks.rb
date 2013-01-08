

Aruba.configure do |config|
  config.before_cmd do |cmd|
    puts "About to run '#{cmd}'"
  end
end

Before do
  @aruba_timeout_seconds = 5
end
