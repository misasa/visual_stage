require 'open3'
require 'tempfile'
require 'yaml'
require 'logger'
module VisualStage
	class VS2007API
		attr_accessor :handle, :data_dir, :path, :name, :python_path, :api_exe

		def initialize(opts = {})
			@verbose = opts[:verbose] || false
			@python_path = opts[:python_path] || "python"
			@api_path = opts[:api_path] || File.join(File.expand_path('../../../bin',__FILE__),'/vs2007api.py')
#			@api_exe = opts[:api_exe] || File.join(File.expand_path('../../../dist',__FILE__),'/vs2007api.exe')
			@api_exe = opts[:api_exe] || 'vs-api.exe'
			@vs_exe_path = "VS2007.exe"
			@api_command_refs_file = File.join(File.dirname(__FILE__), '/api_command_refs.yml')
			@@api_command_refs = YAML.load_file(@api_command_refs_file)
			@handle = get_handle unless opts[:offline]
			@log_dir = File.expand_path('../../../log',__FILE__)
			@log_path = File.join(@log_dir,'/vs2007api.log')
			@log = Logger.new(@log_path)
		end

		def randam_chars(size=7)
			(('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).shuffle[0..size].join
		end

		def add_and_remove_tempfile
			marker = randam_chars
			tf = Tempfile.new(['vs2007','.' + marker])
			tmpfile_path = myexpand_path(tf.path)
			set_marker_position('POINT',0,0)
			new_id = add_address
			set_select_address(new_id)
			add_attach_file(tmpfile_path)
			del_address(new_id)
			return marker
		end

		def connect
			@handle = get_handle
		end

		def get_handle( cnt_retry = 0)
			#print "getting window handle..." if @verbose
			command = "#{@api_exe} -g"
			#p command if @verbose
			out, error, status = Open3.capture3(command)
			vals = out.chomp.split(' ')
	      	status_text = vals.shift
	      	raise 'invalid args' unless status_text == 'SUCCESS'
	      	#@handle = vals[0]
	      	handle = vals[0]
			#print " [#{@handle}]\n" if @verbose
			return handle
	      	rescue => ex
	      		print "NG\n" if @verbose
	      		#start_vs
	      		cnt_retry += 1
	      		retry if cnt_retry < 2
	      		raise "ERROR: could not get window handle for VS"
		end

		def init_address()
			Address.pool.clear
			Address.api = self
			num_address = get_address_count()[0].to_i
			#p num_address
			tf = Tempfile.new(["vs-address-",".txt"])
			tf.close
			exported_path = myexpand_path(tf.path)
			file_export(exported_path)
			raise unless File.exists?(exported_path)
			txt = File.read(exported_path)
			lines = txt.split("\n")
			header = lines.shift
			num_address = lines.size
			lcnt = 0
			address_cnt = 0
			address_list = []
			while address_cnt < num_address
				break if lcnt > 100
				idx = lcnt
				lcnt += 1
				begin
					set_select_address(idx)
	#				p "#{idx} [#{lines[address_cnt]}]"
					Address.pool << Address.from_line(idx, lines[address_cnt].chop)
					address_cnt += 1
				rescue
					next
				end
			end
		end



		def create_address(params = {})
			if params[:locate]
				set_marker_position('POINT', params[:locate])
			end

			address_no = add_address()
			# address_no = vargs[0].to_i
#			data = "<ID:#{address_no}>"
#			data = ""
#			data = params[:data] if params[:data]
			set_address_data(data) if params[:data]
			set_address_name(params[:name]) if params[:name]

			if params[:locate]
			# Locate (  0,   0)
				x,y = params[:locate]
				set_address_locate(x, y)
			elsif params[:x_locate] && params[:y_locate]
				x = params[:x_locate]
				y = params[:y_locate]
				set_address_locate(x,y)
			end
#			file_save
			return address_no
		end


		def cygpath(filepath, option = "u")
			self.class.cygpath(filepath, option)
		end

		def self.cygpath(filepath, option = "u")
			dirname = File.dirname(filepath)
			basename = File.basename(filepath)
			command = "cygpath -#{option} #{dirname}"
			puts "#{command}..." if @verbose
	    	out, error, status = Open3.capture3(command)
	    	cpath = out.chomp
	    	return File.join(cpath, basename)
		end


		def myexpand_path(file_path)
			self.class.myexpand_path(file_path)
		end

	    def self.myexpand_path(file_path)
	        file_path = File.expand_path(file_path)
	        file_path = self.cygpath(file_path, "m") if RUBY_PLATFORM.downcase =~ /cygwin/
	        file_path = file_path.gsub(/\s/,"\ ")
	        return file_path
	    end



		def open(file_path, params = {})
			save_flag = params[:save_flag] || "NO"
			file_path = myexpand_path(file_path)
			dirname = File.dirname(file_path)
			basename = File.basename(file_path)
			file_open(dirname, basename, save_flag)
		end

		def file_new(file_path, params = {})
			save_flag = params[:save_flag] || "NO"
			file_path = myexpand_path(file_path)
			dirname = File.dirname(file_path)
			basename = File.basename(file_path)
			exec_command(api_command('FILE_NEW', [dirname, basename, save_flag]))			
		end

		def file_export(file_path, params = {})
			file_path = myexpand_path(file_path)
			exec_command(api_command('FILE_EXPORT', [file_path]))			
		end

		def set_attach_default_parameter(params = {})
			set_def_attach_name(params[:name]) if params[:name]
			set_def_attach_imag(params[:imag]) if params[:imag]
		end

		def get_attach_default_parameter
			params = Hash.new
			params[:name] = get_def_attach_name()
			params[:imag] = get_def_attach_imag()
			return params
		end

		def size2imag(size)
			osize = get_ms_image_size(1)
			ximag = (osize[0]/size[0]).to_i
			yimag = (osize[1]/size[1]).to_i
			return ximag
		end

		def attach_file(file_path, params = {})
			file_path = myexpand_path(file_path)
			if params[:size]
				params.merge!(:imag => size2imag(params[:size]))
			end
			def_param = get_attach_default_parameter()
			set_attach_default_parameter(params)
			set_marker_position('POINT',params[:locate]) if params[:locate]
			attach_no = add_attach_file(file_path)
			set_select_attach(attach_no, "TRUE")
			attach_class = get_attach_class(attach_no)

			unless attach_class == 0

				# SIZE
				if params[:size]
					width_in_um,height_in_um = params[:size]
					params[:center] = [ width_in_um/2.0, height_in_um/2.0 ] unless params[:center]
#					params[:magnification] = 120_000/width_in_um unless params[:magnification]
					set_attach_size(attach_no, width_in_um, height_in_um)
				end

				# Center
				if params[:center]
					center_x,center_y = params[:center]
					# center_x += point_no * 1000
					set_attach_center(attach_no, center_x, center_y)	
				end

				# Background
				if params[:background]
				#@app.set_select_bg_image(-1)	
					set_select_bg_image(attach_no)
				end
			end
			set_attach_default_parameter(def_param)
#			file_save
			return attach_no
		end

		def select_or_create_address( point_no, cnt_retry = 2 )
			print "selecting address [#{point_no}]..." if @verbose
			set_select_address(point_no)
			print " OK\n" if @verbose
			rescue => ex
				print " NG\n" if @verbose
				add_address()
				cnt_retry += 1
				retry if cnt_retry < point_no
				raise "ERROR: could not select #{point_no}"
		end

		def start_vs
			Open3.popen3(@vs_exe_path)
			#system(@vs_exe_path)
		end


		def command_reflists(key = nil)
			return @@api_command_refs[key.to_sym] if key
			return @@api_command_refs.values
		end

		def command_reflist(key = nil)
			list = []
			lists = command_reflists(key)
			lists.each do |l|
				list.concat(l)
			end
			return list
		end

		def command_ref(key)
			command_reflist.find{|r| r[0] == key}
		end

		#def api_exe()
	    #	"#{@python_path} #{@api_path}"
	  	#end

	  	# def read_response(response)
	   #    	vals = response.split(' ')
	   #    	status_text = vals.shift
	   #    	raise "[#{status_text}]: #{command}" unless status_text == 'SUCCESS'
	   #    	r = vals.shift
	   #    	return r.split(',') if r
	  	# end

	  	def str2val(str)
	  		if integer_string?(str)
	  			return Integer(str)
	  		elsif float_string?(str)
	  			return Float(str)
	  		else
	  			return str
	  		end
	  	end


	  	def integer_string?(str)
	  		Integer(str)
	  		true
	  	rescue ArgumentError
	  		false
	  	end

	  	def float_string?(str)
	  		Float(str)
	  		true
	  	rescue ArgumentError
	  		false
	  	end

	    def exec_command(command)
	    	# puts "#{command}..." if @verbose
	    	# out, error, status = Open3.capture3(command)
	    	# #return out.chomp
	     #  	vals = out.chomp.split(' ')
	     	out = get_stdout(command)
	     	vals = out.chomp.split(' ')
	      	status_text = vals.shift
	      	raise 'invalid args' + " #{command}" unless status_text == 'SUCCESS'
	      	r = vals.shift
	      	if r
	      		rs = r.split(',')
	      		if rs.size == 1
	      			return str2val(rs[0])
	      		else
	      			return rs.map{|s| str2val(s) }
	      		end
	      	else
	      		return true
	      	end
	    end

	    def set_handle()
	      	@handle = exec_command("#{api_exe} -g")[0]
	    end



		def api_command(command = 'TEST_CMD', args)
	       	# line = "#{@python_path} #{@api_path}"
	        param = ""
	        param += "-d #{@handle} " if @handle
	        param += "\"#{command}"
	        param += " #{args.join(',')}" unless args.empty?
	        param += "\""
	        "#{api_exe} #{param}"
	    end

	    def get_stdout(command)
	    	puts "#{command}..." if @verbose
	    	@log.info(command)
	    	out, error, status = Open3.capture3(command)
			res = out.chomp
			@log.info(res)
			puts "#{res}" if @verbose
			return res
	    end

	    def exec_command_and_return_result(ref, args)
	    	command = api_command(ref[0], args)
	      	vals = get_stdout(command).split(' ')
	      	status_text = vals.shift
	      	raise 'invalid args' + " #{command}" unless status_text == 'SUCCESS'
	      	r = vals.shift
	      	return r.split(',') if r
	    end

	    def method_missing(method_id, *args)
	    	ref = command_ref(method_id.to_s.upcase)
	    	if ref
#	    		r = exec_command_and_return_result(ref, args)
	    		r = exec_command(api_command(ref[0], args))
	    		return r
	    	else
	    		super
	    	end
	    end

	end
end
