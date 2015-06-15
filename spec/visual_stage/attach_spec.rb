require 'spec_helper'

module VisualStage
	describe Attach do
		before(:each) do
#			Address.pool << Address.new(:name => 'hello')
			Base.clean
			#Base.api = VS2007API.new(:verbose => true)
			Base.api = double('api')
		end

		describe ".init" do
			before(:each) do
				@data_dir = "tmp/BCG12"
				setup_data(@data_dir)
				Base.data_dir = @data_dir
			end
			it "sets up Attach.pool", :current => true do
				Attach.init
			end
		end

		describe "#get" do
			before(:each) do
				@address_id = 12
				@idx = 0
				@locate = [100,200]
				@center = [20,20]
				@size = [50,100]
				@imag = 50.2
			end
			it " gets information of selected attach" do
				Attach.api.should_receive(:get_select_address).and_return(@address_id)
				Attach.api.should_receive(:get_attach_class).with(@idx).and_return(1)
				Attach.api.should_receive(:get_attach_name).with(@idx).and_return('test')
				Attach.api.should_receive(:get_attach_file).with(@idx).and_return('test.txt')
				Attach.api.should_receive(:get_attach_locate).with(@idx).and_return(@locate)
				Attach.api.should_receive(:get_attach_center).with(@idx).and_return(@center)
				Attach.api.should_receive(:get_attach_size).with(@idx).and_return(@size)
				Attach.api.should_receive(:get_attach_imag).with(@idx).and_return(@imag)
				obj = Attach.get(@idx)
				obj.locate.should == @locate
				obj.center.should == @center
				obj.size.should == @size
				obj.imag.should == @imag

			end
		end

		describe "#create" do

			before(:each) do
				Attach.api = double('api')
				adr = double('address')
				adr.stub(:attach_pool).and_return([])
				Address.stub(:find_by_id).and_return(adr)
			end

			it "sends a api_command" do
				file_path = "tmp/file-1"
				attrib = {:name => "attach-1", :locate => [100.01,200.01], :address_id => 1}
				id = 2
				Attach.api.should_receive(:get_select_address).and_return(-1)
				Attach.api.should_receive(:set_select_address).with(attrib[:address_id])
				Attach.api.should_receive(:attach_file).with(file_path, attrib).and_return(id)
				obj = Attach.create("tmp/file-1", attrib)
				obj.id.should == id
				obj.name.should == attrib[:name]
				obj.locate.should == attrib[:locate]
			end
		end

	end
end