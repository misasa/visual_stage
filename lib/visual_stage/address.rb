require 'tempfile'
module VisualStage
	class Address < Base
		@@pool = []
		@@api = nil
		@@empty_ids
		attr_accessor :id, :address_class, :name, :x_locate, :y_locate, :data

		def self.empty_ids
			@@empty_ids ||= self.get_empty_ids
		end

		def self.clear
			@@empty_ids = nil
			@@pool = []
		end

		def self.init_by_export
			raise "must open file" unless self.current?
			self.clear
			exported_path = self.export
			txt = File.read(exported_path)
			lines = txt.split("\n")
			header = lines.shift
			num_address = lines.size
			lcnt = 0
			address_cnt = 0
			address_list = []
			while address_cnt < num_address
				#break if lcnt > 100
				idx = lcnt
				lcnt += 1
				next if self.empty_ids.include?(idx)
				#p "#{idx} [#{lines[address_cnt]}]"
				addr = self.from_line(idx, lines[address_cnt].chop)
				unless addr.local_id && addr.local_id == idx
					addr.update_local_id(idx)
				end
				self.pool << addr
				address_cnt += 1
			end
			file_save			
		end

		def self.refresh_by_export
			raise "must open file" unless self.current?
			exported_path = self.export
			txt = File.read(exported_path)
			lines = txt.split("\n")
			header = lines.shift
			num_address = lines.size
			lcnt = 0
			address_cnt = 0
			address_list = []
			#puts lines
			tpool = lines.map{|line| self.from_line(nil, line.chop)}
			if tpool.all? {|addr| !addr.id.nil? }
				@@pool = tpool
			else
				self.init
			end
			nil
		end

		def self.get_empty_ids
			raise "must open file" unless self.current?
			empty_address_ids = []			
			address_count = api.get_address_count
			return empty_address_ids if address_count == 0
			tcount = address_count
			loop {
				new_id = api.add_address
				break if new_id == tcount
				empty_address_ids << new_id
				tcount += 1
			}
			remove_ids = empty_address_ids.dup
			remove_ids << tcount
			remove_ids.each do |id|
				api.set_select_address(id)
				api.del_address()
			end

			return empty_address_ids
		end


		def initialize(opts = {})
			@id = nil
			@address_class = opts[:address_class]
			@name = opts[:name][0,20] if opts[:name]
			if opts[:locate] && opts[:locate].size == 2
				@x_locate = opts[:locate][0].to_f
				@y_locate = opts[:locate][1].to_f
			end
			@x_locate = opts[:x_locate].to_f if opts[:x_locate]
			@y_locate = opts[:y_locate].to_f if opts[:y_locate]
			@data = opts[:data]
			@attach_pool = []
		end

		def self.clean
			@@pool = []
		end

		def self.pool
			@@pool
		end

		def self.api
			@@api
		end

		def api
			self.class.api
		end

		def self.api=(api)
			@@api = api
		end

		# def self.from_line(id, line)
		# 	vals = line.split("\t")
		# 	obj = self.new(:address_class => vals[0], :name => vals[1], :x_locate => vals[2].to_f, :y_locate => vals[3].to_f, :data => vals[4])
		# 	if id
		# 		obj.id = id
		# 	else
		# 		obj.id = obj.local_id
		# 	end
		# 	return obj
		# end

		def self.from_line(line)
			vals = line.split("\t")
			obj = self.new(:address_class => vals[1].to_i, :name => vals[2], :x_locate => vals[3].to_f, :y_locate => vals[4].to_f, :data => vals[5])
			obj.id =vals[0].to_i
			return obj
		end


		def self.all
			@@pool
		end

		def self.find_by_id(id)
			pool.find{|adr| adr.id == id}
		end

		def self.find_by_name(name)
			pool.find{|adr| adr.name == name[0,20]}
		end

		def self.find_all_by_name(name)
			pool.select{|adr| adr.name == name[0,20] }
		end

		def self.find_or_create_by_name(name, attributes = {})
			adr = find_by_name(name)
			if adr
				return adr
			else
				create(attributes.merge({:name => name}))
			end
		end

		def self.create(attributes)
			obj = self.new(attributes)
			raise "could not use api" unless api
			id = api.create_address(attributes)
			obj.id = id
			self.pool << obj
			self.set_flag_save
			return obj
		end

		def select
			api.set_select_address(id)
		end

		def attach_pool
			@attach_pool
		end

		def refresh
#			init_attach_pool
		end

		def empty_attach_ids
			@empty_attach_ids ||= get_empty_attach_ids
		end

		def attach_ids
			@attach_ids ||= get_attach_ids
		end

		def get_empty_attach_ids
			empty_attach_ids = []			
			attach_count = api.get_attach_count
			return empty_attach_ids if attach_count == 0
			tcount = attach_count
			loop {
				tf = Tempfile.new('VS2007')
				tmpfile_path = Base.myexpand_path(tf.path)
				new_id = api.add_attach_file(tmpfile_path)
				#new_id = api.add_attach
				break if new_id == tcount
				empty_attach_ids << new_id
				tcount += 1
			}
			remove_ids = empty_attach_ids.dup
			remove_ids << tcount
			remove_ids.each do |id|
				api.set_select_attach(id)
				api.del_attach()
			end

			return empty_attach_ids
		end


		def init_attach_pool
#			p "init_attach_pool..."
			api.set_select_address(self.id)
			num_attach = api.get_attach_count
			attach_cnt = 0
			llcnt = 0
			while attach_cnt < num_attach
				break if llcnt > 100
				iidx = llcnt
				begin
					Attach.select(iidx)
					attach = Attach.get(iidx)
					@attach_pool << attach
					attach_cnt += 1
				rescue => ex
					p ex
				end
				llcnt += 1
			end			
		end

		def find_attach_all
			refresh
			attach_pool
		end

		def find_attach_by_id(id)
			refresh
			attach_pool.find{|at| at.id == id }			
		end

		def find_attach_by_name(name)
			refresh
			attach_pool.find{|at| at.name == name[0,20] }			
		end

		def find_attach_by_file(file)
			refresh
			attach_pool.find{|at| at.file == file }			
		end

		def self.find_or_create_attach(filepath, attributes = {})
			basename = File.basename(filepath)
			addr = self.find_or_create_by_name(basename)
			at = addr.find_attach_by_name(basename)
			if at
				return at
			else
				return Attach.create(filepath, attributes.merge({:name => basename, :file => basename, :address_id => addr.id}))				
			end
		end

		def find_or_create_attach(filepath, attributes = {})
			basename = File.basename(filepath)
			at = find_attach_by_name(basename)
			if at
				return at
			else
				return Attach.create(filepath, attributes.merge({:name => basename, :file => basename, :address_id => self.id}))				
			end
		end

		def self.find_or_create_attach_by_name(name, filepath, attributes = {})
			addr = self.find_or_create_by_name(name)

			at = addr.find_attach_by_name(name)
			if at
				return at
			else
				return Attach.create(filepath, attributes.merge({:name => name, :address_id => addr.id}))				
			end
		end

		def find_or_create_attach_by_name(name, filepath, attributes = {})
			at = find_attach_by_name(name)
			if at
				return at
			else
				return Attach.create(filepath, attributes.merge({:name => name, :address_id => self.id}))				
			end
		end

		def local_id
			m = /\<ID\:(\d+)\>/.match(data)
	  		Integer(m[1])
	  	rescue
	  		nil
		end

		def local_id=(lid)
			if local_id
				id_str = self.data
				id_str.gsub!(/\<ID:\d+\>/, "<ID:#{lid}>")
			else
				id_str = "<ID:#{lid}>"
				id_str += self.data if self.data
			end
			self.data = id_str
		end

		def update_local_id(lid, flag_save = false)
			self.local_id = lid
			api.set_select_address(lid)
			api.set_address_data(self.data)
			if flag_save
				api.file_save
				self.data = api.get_address_data()
			end
		end

		def locate
			[x_locate, y_locate]
		end

		def locate=(locate)
			x_locate = locate[0]
			y_locate = locate[1]
		end

	end
end