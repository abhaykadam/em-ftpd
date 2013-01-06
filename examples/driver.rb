require 'aws-sdk'
require 'csv'
require 'tempfile'

class Driver
	def initialize (key, secret, bucket)
		@aws_key, @aws_secret, @aws_bucket = key, secret, bucket
		AWS.config(
			:access_key_id => @aws_key, 
			:secret_access_key => @aws_secret
		)		
	end	
	
	# boolean indicating if the provided details are valid
	def authenticate(user, pass, &block)
		get_passwd_file do |passwd|	
			@users = extract_users(passwd)

			if @users[user] && @users[user][:pass] == pass
				@user = user
				yield true
			else
				yield false				
			end
		end		
	end	

	# an integer with the number of bytes in the file or nil if the file
	# doesn't exist
	def bytes(path, &block)
		path = path[1..-1] if path.start_with?("/")

		s3 = AWS::S3.new
		bucket = s3.buckets[@aws_bucket]
		if bucket.objects[path].exists?
			yield bucket.objects[path].content_length
		else
			yield nil
		end
		
	end

	# a boolen indicating if the current user is permitted to change to the
	# requested path
	def change_dir(path, &block)
		yield true
	end

	# an array of the contents of the requested path or nil if the dir
	# doesn't exist. Each entry in the array should be
	# EM::FTPD::DirectoryItem-ish
	def dir_contents(path, &block)
		s3 = AWS::S3.new
		bucket, root = @aws_bucket.split("/")
		puts bucket, root, path
		bucket = s3.buckets[bucket]
		tree = bucket.as_tree(:prefix => path)
		directories = tree.children.select(&:branch?).collect(&:prefix)
		list = []
		directories.each { |dir|
			list << dir_item(dir)
		}
		files = tree.children.select(&:leaf?).collect(&:key)
		files.each { |file|
			list << file_item(file, bucket.objects[file].content_length)
			puts bucket.objects[file].content_length
		}
		
		yield list
	end

	# a boolean indicating if path was successfully created as a new directory
	def make_dir(path, &block)
		s3 = AWS::S3.new
		bucket = s3.buckets[@aws_bucket]
		puts bucket.name
		object = bucket.objects.create(path + '/test.txt', 'abhay')

		yield false
	end

	def get_file(path, &block)
		path = path[1..-1] if path.start_with?("/")
		s3 = AWS::S3.new
		bucket = s3.buckets[@aws_bucket]
		
		tmpfile = Tempfile.new('em-ftpd')
		
		bucket.objects[path].read do |chunk|
			tmpfile.write(chunk)
		end	

		tmpfile.flush
		tmpfile.seek(0)
		yield tmpfile
	end

	# a boolean indicating if the directory was successfully deleted
	#def delete_dir(path, &block)
	#	s3 = AWS::S3.new
	#	bucket = s3.buckets[@aws_bucket]
	#	yield bucket.objects[path].delete == nil ? true : false 
	#end

	# an integer indicating the number of bytes received or False if there
	# was an error
	def put_file_streamed(path, datasocket, &block)
		path = path[1..-1] if path.start_with?("/")
		s3 = AWS::S3.new
		bucket = s3.buckets[@aws_bucket]
		object = bucket.objects.create(path, '')
		datasocket.on_stream { |chunk|
			object.write(chunk)	
		}

		yield object.content_length
	end

	private

	def get_passwd_file (&block)
		s3 = AWS::S3.new
		bucket = s3.buckets[@aws_bucket]
		passwd = bucket.objects['passwd']
		yield passwd.read()
	end

	def extract_users (passwd)
		users = {}
		CSV.parse(passwd).each { |row|
			users[row[0].strip] = {
				:pass => row[1].strip,
				:admin =>row[2].to_s.strip.upcase == 'Y'
			}
		}
		
		users
	end

	def dir_item(name)
		EM::FTPD::DirectoryItem.new(:name => name, :directory => true, :size => 0)
	end

	def file_item(name, bytes)
		EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => bytes)
	end
end
