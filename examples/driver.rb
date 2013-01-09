require 'aws-sdk'
require 'csv'
require 'tempfile'

class Driver
	def initialize (key, secret, bucket)
		@aws_key, @aws_secret, @aws_bucket = key, secret, bucket
		AWS.config(
			:access_key_id => @aws_key, 
			:secret_access_key => @aws_secret,
			:s3_multipart_min_part_size => 10
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
		path = lstrip_slash(path)

		if bucket.objects[path].exists?
			yield bucket.objects[path].content_length
		else
			yield nil
		end
		
	end

	# a boolen indicating if the current user is permitted to change to the
	# requested path
	def change_dir(path, &block)
		if admin? || path.start_with?('/' + @user + '/')
			yield true
		else
			yield false
		end
	end

	# an array of the contents of the requested path or nil if the dir
	# doesn't exist. Each entry in the array should be
	# EM::FTPD::DirectoryItem-ish
	def dir_contents(path, &block)
		path = path + '/' unless path.end_with?('/')
		bucket_path, root = @aws_bucket.split("/")

		tree = bucket(bucket_path).as_tree(:prefix => root+path)
		directories = tree.children.select(&:branch?).collect(&:prefix)
		files = tree.children.select(&:leaf?).collect(&:key)

		list = []
		directories.each { |dir|
			list << EM::FTPD::DirectoryItem.new(:directory => true, :name => dir.split('/').last, :time =>bucket(bucket_path).objects[dir].last_modified, :size => 0)
		}
		files.each { |file|
			unless (file == root+path)
				list << EM::FTPD::DirectoryItem.new(:directory => false, :name => file.split('/').last, :time =>bucket(bucket_path).objects[file].last_modified, :size => bucket(bucket_path).objects[file].content_length)
			end
		}
		
		yield list
		
	end

	# a boolean indicating if the directory was successfully deleted
	def delete_dir(path, &block)
		path = lstrip_slash(path)
		path = path + '/' unless path.end_with?('/')

		object = bucket.objects[path]
		puts path, object.exists?
		unless object.exists?
			yield false
		else		
			yield object.delete.nil?
		end
	end

	# a boolean indicating if path was successfully created as a new directory
	def delete_file(path, &block)
		path = lstrip_slash(path)

		object = bucket.objects[path]
		unless object.exists?
			yield false
		else		
			yield object.delete.nil?
		end
	end

	#na boolean indicating if from_path was successfully renamed to to_path
	def rename(from_path, to_path, &block)
		from_path = lstrip_slash(from_path)
		to_path = lstrip_slash(to_path)		

		old_obj = bucket.objects[from_path]
		unless old_obj.exists?
			yield false
		else
			new_obj = old_obj.move_to(to_path)
			yield new_obj.exists?
		end
	end

	# a boolean indicating if path was successfully created as a new directory	
	def make_dir(path, &block)
		path = lstrip_slash(path)
		path = path + '/' unless path.end_with?('/')
		object = bucket.objects.create(path, '')
		yield object.exists?
	end

	def get_file(path, &block)
		path = lstrip_slash(path)
		
		unless bucket.exists? 
			yield false
		end
		
		tmpfile = Tempfile.new('em-ftpd')
		
		begin
			bucket.objects[path].read do |chunk|
				tmpfile.write(chunk)
			end
		rescue AWS::S3::Errors::NoSuchKey
			yield false		
		end	

		tmpfile.flush
		tmpfile.seek(0)
		yield tmpfile
	end

	# an integer indicating the number of bytes received or False if there
	# was an error
	def put_file_streamed(path, datasocket, &block)
		path = lstrip_slash(path)
		upload = bucket.objects[path].multipart_upload
		id = upload.id
		part_number = 1
		@buffer = ""
		datasocket.on_stream { |chunk|

			@buffer << chunk
			if @buffer.size > (5 * 1024 * 1024)
				upload = bucket.objects[path].multipart_uploads[id]
				upload.add_part(@buffer, :part_number => part_number)
				part_number += 1
				@buffer = ""
			end
		}

		datasocket.callback {
			upload = bucket.objects[path].multipart_uploads[id]
			if @buffer.size != 0
				upload = bucket.objects[path].multipart_uploads[id]
				upload.add_part(@buffer, :part_number => part_number)
				@buffer = ""
			end
			upload.complete(:remote_parts)
			yield bucket.objects[path].content_length
		}
		datasocket.errback {
          		yield false
        	}
	end

	private

	def bucket(bucket_path=@aws_bucket)
		s3 = AWS::S3.new
		bucket = s3.buckets[bucket_path]
		bucket
	end

	def get_passwd_file (&block)
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

	def admin?
		@users[@user] && @users[@user][:admin]
	end

	def lstrip_slash(string)
		string[1..-1] if string.start_with?("/")
	end
end
