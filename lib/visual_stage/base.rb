require 'find'
require 'tempfile'
module VisualStage
	class Base
		@@api = nil
		@@verbose = false
		@@logger = Logger.new(STDERR)
		@@data_dir = nil
		#@@netpath_exe_path = File.join(File.expand_path('../../../dist',__FILE__),'/netpath.exe')
		@@last_address_dat_stat = nil
		@@flag_save = nil

		def self.verbose
			@@verbose
		end

		def self.verbose=(verbose) 
			@@verbose = verbose; 
		end

		def self.api
			@@api
		end

		def self.api=(api) 
			@@api = api; 
		end

		def self.data_dir
			@@data_dir
		end
		
		def self.data_dir=(path)
			if FileTest.directory?(path)
				@@data_dir = path;
			else
				raise "#{path} does not exist or is not directory."
			end
		end

		def self.last_address_dat_stat() @@last_address_dat_stat; end
		def self.last_address_dat_stat=(stat) @@last_address_dat_stat = stat; end

		def self.flag_save() @@flag_save; end
		def self.set_flag_save() @@flag_save = true; end

		def self.is_netpath?(path)
			path = path.gsub(/\\/,'/')
			path =~ /^\/\// ? true : false
		end

	    def self.myexpand_path(file_path)
	        file_path = File.expand_path(file_path)
	        file_path = self.cygpath(file_path, "m") if RUBY_PLATFORM.downcase =~ /cygwin/
	        file_path = self.netpath(file_path, "m") if self.is_netpath?(file_path)
	        return file_path
	    end

		def self.cygpath(filepath, option = "m")
			dirname = File.dirname(filepath)
			basename = File.basename(filepath)
			command = "cygpath -#{option} \"#{dirname}\""
			puts "#{command}..." if @verbose
	    	out, error, status = Open3.capture3(command)
	    	cpath = out.chomp
	    	return File.join(cpath, basename)
		end

		def self.netpath(filepath, option = "m")
			filepath = filepath.gsub(/\\/,'/')
			#filepath = cygpath(File.expand_path(filepath))
			dirname = File.dirname(filepath)
			basename = File.basename(filepath)
			command = "#{@@netpath_exe_path} -#{option} #{dirname}"
			puts "#{command}..." if @verbose
	    	out, error, status = Open3.capture3(command)
	    	puts "#{out}" if @verbose
	    	cpath = out.chomp
	    	return File.join(cpath, basename)
		end

		def self.localpath(filepath)
			filepath = filepath.gsub()
		end

		def self.find_path_from_log(marker)
			log = VS2007Mon.log
			return log[:path].find{|path| /\.#{marker.downcase}\.txt$/.match(path) }			
		end

		# def self.get_data_dir
		# 	return unless self.current?
		# 	VS2007Mon.start unless VS2007Mon.is_running?
		# 	marker = api.add_and_remove_tempfile
		# 	VS2007Mon.stop
		# 	dpath = find_path_from_log(marker)
		# 	data_dir = File.dirname(self.myexpand_path(dpath))
		# end

		def self.get_data_dir
			return unless self.current?
			pwd = VS2007.pwd
			return unless pwd
			data_dir = self.myexpand_path(pwd)
		end

		def self.address_dat_path
			return unless data_dir
			File.join(data_dir,'ADDRESS.DAT')
		end

		def self.address_dat_is_updated?
			return unless self.address_dat_path
			address_dat_stat = File::Stat.new(self.address_dat_path)
			cmp = address_dat_stat <=> self.last_address_dat_stat
			self.last_address_dat_stat = address_dat_stat
			return cmp == 0 ? false : true
		end


		def self.stringz(string)
			string.unpack("Z*").at(0)
		end

		def self.load_data
			return unless self.current?
#			print "loading..."			
			Address.clean
			txt = VS2007.addresslist
			return unless txt
			lines = txt.split("\r\n")
			lines.each do |line|
				addr = Address.from_line(line)
				Address.pool << addr
			end

			txt = VS2007.attachlist
			return unless txt
			lines = txt.split("\r\n")
			lines.each do |line|
				vals = line.split("\t")
				address_id = vals[0].to_i
				addr = Address.find_by_id(address_id)
				next unless addr
				attach_id = vals[1].to_i
				att = Attach.from_line(line)
				att.id = attach_id
				addr.attach_pool << att
			end

#			print " [OK]\n"
		end

		def self.load_data_from_file
			return unless self.address_dat_path
			return unless self.address_dat_is_updated?
			print "#{self.address_dat_path} loading..."
			Address.clean
			io = File.open(self.address_dat_path)
			dat = AddressDAT.new
			dat.read(io)
			dat.snapshot.addresses.each do |h_address|
				h_address[:name] = stringz(h_address[:name])
				h_address[:data] = stringz(h_address[:data])				
				adr = Address.new(h_address)
				adr.id = h_address[:no]
				h_address.attachs.each do |h_attach|
					h_attach[:name] = stringz(h_attach[:name])
					h_attach[:file] = stringz(h_attach[:file])
					att = Attach.new(h_attach)
					att.id = h_attach[:no]
					adr.attach_pool << att
				end
				Address.pool << adr				
			end
			io.close
			print " [OK]\n"
		end

		def self.connect(opts= {})
			opts = {:verbose => @@verbose, :logger => @@logger}.merge(opts)
			self.api = VS2007API.new(opts)
		rescue
			nil
		end

		def self.connected?
			if self.api
				true
			else
				false
			end
		end

		def self.file_save
			if flag_save
				print "saving |#{self.address_dat_path}|..."
				self.api.file_save()
				print " [OK]\n"
				@@flag_save = false

			end
		end


		def self.clean
			@@api = nil
			@@data_dir = nil
			@@flag_save = nil
			@@last_address_dat_stat = nil
			Address.clean
		end

		# def self.detect_current_dir
		# 	Find.find("/cygdrive/y") {|f|
		# 		p f
		# 	}
		# end

		# def self.detect_current_dir
		# 	# Dir.glob("/cygdrive/y/**/ADDRESS.DAT"){|path|
		# 	# 	p path
		# 	# }
		# 	# Find.find("/cygdrive/c/VS2007data"){|path|
		# 	# 	p "[#{path}]"
		# 	# 	if FileTest.directory?(path)
		# 	# 		p "DIR:#{path}"
		# 	# 		Find.prune
		# 	# 	else
		# 	# 		p "skipping..."
		# 	# 		next
		# 	# 	end
		# 	# }

		# end

		def self.current?
			self.connect unless api
			return false unless api
			path = VS2007.pwd
			if path
				return true
			else
				return false
			end
			# begin
			# 	api.get_select_address
			# 	return true
			# rescue
			# 	return false
			# end
		end

		def self.world2stage(points_on_world)
			raise "no VS process" unless api
			raise "invalid args" unless points_on_world.size == 2
			points_on_stage = api.chg_world_to_stage(points_on_world[0], points_on_world[1])
			raise "invalid args" unless points_on_stage.size == 2
			return points_on_stage
		end

		def self.refresh_by_export
			raise "must open file" unless self.current?
			Address.pool.clear
#			Attach.pool.clear
			exported_path = self.export
			txt = File.read(exported_path)
			lines = txt.split("\n")
			header = lines.shift
			num_address = lines.size
			lines.each do |line|
				Address.pool << Address.from_line(nil, line)
			end
		end

		def self.init
			raise "must open file" unless self.current?
			self.data_dir = self.get_data_dir unless self.data_dir
			self.load_data			
#			Address.init
		end

		def self.refresh
			raise "must open file" unless self.current?
			unless self.data_dir
				self.data_dir = self.get_data_dir
			else
				self.file_save
			end
			self.load_data
		end

		def self.init_address
			Address.init
		end

		def self.init_all
			raise "must open file" unless self.current?
			init_address
			init_attach
			return
			while address_cnt < num_address
				break if lcnt > 100
				idx = lcnt
				lcnt += 1
				begin
					api.set_select_address(idx)
	#				p "#{idx} [#{lines[address_cnt]}]"
					addr = Address.from_line(idx, lines[address_cnt].chop)
					unless addr.local_id
						addr.update_local_id(idx)
					end
					Address.pool << addr
					address_cnt += 1
					begin					
						num_attach = api.get_attach_count
						attach_cnt = 0	
						llcnt = 0
						while attach_cnt < num_attach
							break if llcnt > 100
							iidx = llcnt
							api.set_select_attach(iidx)
							attach = Attach.get(iidx)
							Attach.pool << attach
							attach_cnt += 1
							llcnt += 1
						end
					rescue
						next
					end
				rescue
					next
				end
			end
		end

		def self.create(path, opts = {})
			self.connect unless api			
			raise "no VS process" unless api
			api.file_new(path, opts)
		end

		def self.open_or_create(path, opts = {})
			self.connect unless api			
			raise "no VS process" unless api
			begin
				api.open(path, opts)
			rescue
				api.file_new(path, opts)
			end
		end

		def self.open(path, opts = {})
			self.connect unless api
			raise "no VS process" unless api
			api.open(path)
			self.data_dir = path
			self.load_data
		end

		def self.close(flag = "NO")
			raise "no VS process" unless api
			api.file_close(flag)
			@@data_dir = nil
		end

		def self.export(path = nil)
			unless path
				tf = Tempfile.new(["vs-address-",".txt"])
				tf.close
				path = tf.path
			end
			api.file_export(path)
			raise unless File.exists?(path)
			return path
		end
	end
end
