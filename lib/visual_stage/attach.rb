module VisualStage
	class Attach < Base
		@@pool = []
		@@api = nil

		def self.pool
			@@pool
		end

		def self.api
			@@api
		end

		def self.api=(api)
			@@api = api
		end

		def self.init
			raise "must specify data_dir" unless self.data_dir

			Dir.glob(self.data_dir + '/[0-9]*.txt'){|path|
				basename_with_original_ext = File.basename(path, ".txt")
				basename = File.basename(basename_with_original_ext,".*")
				address_id, attach_no = basename.split('_').map(&:to_i)
				opts = Hash.new
				opts[:file] = basename_with_original_ext
				if false
					lines = File.read(path).split("\r\n")
					opts = Hash.new
					opts[:name] = lines[0]
					opts[:file] = lines[1]
					opts[:locate] = lines[2].split(',').map(&:to_f) if lines[2]
					opts[:imag] = lines[3].to_f if lines[3]
				end
				obj = self.new(opts)
				obj.address_id = address_id
				obj.id = attach_no
				self.pool << obj
			}
		end

		def self.get(id)
			address_id = api.get_select_address(id)
			params = {}
			params[:attach_class] = api.get_attach_class(id)
			params[:name] = api.get_attach_name(id)
			params[:file] = api.get_attach_file(id)
			if params[:attach_class] != 0
				params[:locate] = api.get_attach_locate(id)
				params[:center] = api.get_attach_center(id)
				params[:size] = api.get_attach_size(id)
				params[:imag] = api.get_attach_imag(id)
			end
			obj = self.new(params)
			obj.address_id = address_id
			obj.id = id
			obj
		end

		def self.select(id, opts = {})
			select_flag = "TRUE"
			if opts[:no_select]
				select_flag = "FALSE"
			end
			api.set_select_address(opts[:address_id]) if opts[:address_id]
			api.set_select_attach(id,select_flag)
		end

		def self.create(path, attributes = {})
			obj = self.new(attributes)
			raise "could not use api" unless api			
			address_id = api.get_select_address()
			if attributes[:address_id] && attributes[:address_id] != address_id
				api.set_select_address(attributes[:address_id])
				address_id = attributes[:address_id]
			end
			raise "could not get selected address" if address_id == -1
			id = api.attach_file(path, attributes)
			obj.id = id
			obj.address_id = address_id
			adr = Address.find_by_id(address_id)
			adr.attach_pool << obj
			#self.pool << obj
			self.set_flag_save			
			return obj
		end

		def self.from_line(line)
			vals = line.split("\t")
			address_id = vals[0].to_i
			attach_id = vals[1].to_i
			attach_class = vals[2].to_i

			h = {:attach_class => attach_class, :name => vals[3], :file => vals[4]}

			if attach_class != 0
				h[:x_locate] = vals[5].to_f
				h[:y_locate] = vals[6].to_f
				h[:x_center] = vals[7].to_f
				h[:y_center] = vals[8].to_f
				h[:x_size] = vals[9].to_f
				h[:y_size] = vals[10].to_f
				h[:imag] = vals[11].to_i
			end

			obj = self.new(h)
			obj.id =attach_id
			return obj
		end


		attr_accessor :address_id, :id, :attach_class, :name, :file, :x_locate, :y_locate, :x_center, :y_center, :x_size, :y_size, :imag, :data
		def initialize(opts = {})
			@id = nil
			@attach_class = opts[:attach_class]
			@name = opts[:name]
			@file = opts[:file]
			if opts[:locate] && opts[:locate].size == 2
				@x_locate = opts[:locate][0].to_f
				@y_locate = opts[:locate][1].to_f
			end
			@x_locate = opts[:x_locate].to_f if opts[:x_locate]
			@y_locate = opts[:y_locate].to_f if opts[:y_locate]

			if opts[:center] && opts[:center].size == 2
				@x_center = opts[:center][0].to_f
				@y_center = opts[:center][1].to_f
			end
			@x_center = opts[:x_center].to_f if opts[:x_center]
			@y_center = opts[:y_center].to_f if opts[:y_center]

			if opts[:size] && opts[:size].size == 2
				@x_size = opts[:size][0].to_f
				@y_size = opts[:size][1].to_f
			end
			@x_size = opts[:x_size].to_f if opts[:x_size]
			@y_size = opts[:y_size].to_f if opts[:y_size]

			@imag = opts[:imag]
			#@data = opts[:data]
		end

		def locate
			[@x_locate, @y_locate]
		end

		def locate=(array)
			if array && array.size == 2
				@x_locate = array[0].to_f
				@y_locate = array[1].to_f				
			end			
		end


		def center
			[@x_center, @y_center]
		end

		def center=(array)
			if array && array.size == 2
				@x_center = array[0].to_f
				@y_center = array[1].to_f				
			end
		end


		def size
			[@x_size, @y_size]
		end

		def size=(array)
			if array && array.size == 2
				@x_size = array[0].to_f
				@y_size = array[1].to_f				
			end			
		end


	end
end