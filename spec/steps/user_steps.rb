require 'visual_stage'
include VisualStage
def output
 	@output ||= double('output').as_null_object
end

#let(:output) { double('output').as_null_object }

step "I am not yet playing" do
 	@output = double('output').as_null_object
 	VisualStage::VS2007.stop if VisualStage::VS2007.is_running?
 	VisualStage::Base.clean
end

step "there are the following files:" do |table|
	@files = {}
	table.hashes.each do |hash|
		param = Hash.new
		param[:name] = File.basename(hash['path'],".*")
		param[:imag] = hash['imag'].to_f
		param[:locate] = [hash['locate_x'].to_f, hash['locate_y'].to_f]
		param[:size] = [hash['size_x'].to_f, hash['size_y'].to_f]		
		@files[hash['path']] = param
	end
	@files.each do |path, param|
		setup_file(path)
	end
end

step "I have a empty directory :dirname" do |dirname|
	deleteall(dirname) if File.directory?(dirname)
	FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
end

step "I have a file :filename" do |arg1|
	setup_file(arg1)
end

step "I have a VisualStage data :dirname" do |dirname|
	setup_data(dirname)
end

step "I can start VisualStage" do
	VisualStage::VS2007.start
end

step "I can open :dirname" do |dirname|
	VisualStage::Base.open(dirname)
end

step "I have started VisualStage" do
	VisualStage::VS2007.start
	VisualStage::Base.connect unless VisualStage::Base.connected?
end

step "I have started VisualStage with :dirname" do |dirname|
	VisualStage::VS2007.start
	VisualStage::Base.open(dirname)
	VisualStage::Base.clean
end

step "I have opened VisualStage with :dirname" do |dirname|
	VisualStage::Base.close("YES") if VisualStage::Base.current?

	setup_data(dirname)
	VisualStage::Base.open(dirname)
end

step "I start a new app" do
	VisualStage::Base.init
#	VisualStage::Base.refresh
end

step "I can initialize app" do
	VisualStage::Base.init
end

step "I can refresh app" do
	VisualStage::Base.refresh
end

step "I start a new app with empty addresses" do
	empty_address_ids = [51,53,60,61,62]
	empty_address_ids.each do |rid|
		VisualStage::Base.api.set_select_address(rid)
		VisualStage::Base.api.del_address
	end
	Address.init
#	VisualStage::Base.refresh
end

step "I add new address without local_id" do
	VisualStage::Base.api.add_address
end

step "I can save" do
	VisualStage::Base.file_save()
end

step "I can close" do
	VisualStage::Base.close
end

step "I can stop VisualStage" do
	VisualStage::VS2007.stop
end

step "I can Address.refresh" do
	Address.refresh
end

step "I can Address.find_by_id with :id" do |id|
	adr = Address.find_by_id(id.to_i)
	adr.id.should eql(id.to_i)
end


step "I can Address.find_or_create_attach with :path" do |path|
	Address.find_or_create_attach(path)
#	p Address.find_by_id(id.to_i)
end

step "I can Address#find_or_create_attach with :path" do |path, param|
	basename = File.basename(path)
	adr = Address.find_or_create_by_name(basename, param)
	adr.select
#	at = adr.find_or_create_attach(path, param)
	at = adr.find_or_create_attach(path, :name => basename, :imag => param[:imag])	
#	p Address.find_by_id(id.to_i)
end

step "I can Address#find_or_create_attach with param :path" do |path|
	param = @files[path]
	basename = File.basename(path,".*")
	param.merge(:name => basename)
	adr = Address.find_or_create_by_name(basename, param)
	adr.select
	at = adr.find_or_create_attach(path, param)	
end

step "I can addr.find_or_create_attach_by_name with name :name and path :path" do |name, path|
	param = @files[path]
	basename = File.basename(path,".*")
	param.merge(:name => basename)
	adr = Address.find_or_create_by_name(name, param)
	adr.select
	at = adr.find_or_create_attach_by_name(basename, path, param)
end

step "I can Address.find_all_by_name with :name" do |name|
	adrs = Address.find_all_by_name(name)
	adrs.each do |adr|
		adr.name.should eql(name)
	end
end

step "I can Address.find_or_create_by_name with :name" do |name|
	adr = Address.find_or_create_by_name(name)
	adr.name.should eql(name)
end