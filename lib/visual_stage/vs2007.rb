require 'open3'
require 'tempfile'
require 'yaml'
require 'logger'
module VisualStage
	class VS2007
		attr_accessor :handle, :data_dir, :path, :name, :python_path, :api_exe

#		@@exe_path = File.join(File.expand_path('../../../dist',__FILE__), '/vs2007.exe')
		@@exe_path = 'vs.exe'
		@@verbose = false
#		@@pid = nil

#		def self.pid() @@pid end
		def self.exe_path() @@exe_path end
		def self.exe_path=(path) @@exe_path = path end
		def self.verbose() @@verbose end
		def self.verbose=(bool) @@verbose = bool end

	    def self.get_stdout(command)
	    	puts "#{command}..." if verbose
	    	out, error, status = Open3.capture3(command)
			res = out.chomp
			puts "#{res}" if @verbose
			return res
	    end

		def self.start()
			command_line = "#{exe_path} start"
			system(command_line)
			if pid
				return "SUCCESS #{pid}"
			else
				return "FAILED"
			end
		end

		def self.stop()
			command_line = "#{exe_path} stop"
			get_stdout(command_line)			
		end

		def self.status()
			command_line = "#{exe_path} status"
			get_stdout(command_line)
		end

		def self.pid()
	      	vals = status.split(' ')
	      	status_text = vals.shift
	      	if status_text == "RUNNING"
	      		return vals.shift.to_i
	      	else
	      		return nil
	      	end
		end

		def self.is_running?
			self.pid ? true : false
		end

		def self.is_stopped?
			!is_running?
		end

		def self.pwd
			command_line = "#{exe_path} pwd"
			path = get_stdout(command_line)
			if path.empty?
				return nil
			else
				return path
			end
		end

		def self.addresslist(iid = nil)
			#command_line = "#{exe_path} export address"
			command_line = "#{exe_path} list address"
			command_line += " #{iid}" if iid
			list = get_stdout(command_line)
			if list.empty?
				return nil
			else
				return list
			end
		end

		def self.attachlist(iid = nil)
			#command_line = "#{exe_path} export attach"
			command_line = "#{exe_path} list attach"
			command_line += " #{iid}" if iid
			list = get_stdout(command_line)
			if list.empty?
				return nil
			else
				return list
			end
		end



	end
end
