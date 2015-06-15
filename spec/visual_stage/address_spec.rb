require 'spec_helper'

module VisualStage
	describe Address do
		before(:each) do
#			Address.pool << Address.new(:name => 'hello')
		end



		describe ".get_empty_ids" do
			it "returns empty_ids" do
				address_ids = [0]
				if address_ids.empty?
					max = 0
				else
					max = address_ids.max
				end
				full_ids = (0..max).to_a
				empty_ids = full_ids - address_ids
				remove_ids = empty_ids.dup
				remove_ids << max + 1
				address_count = address_ids.count
				Base.should_receive(:current?).and_return(true)
				Base.api.should_receive(:get_address_count).and_return(address_count)
				Base.api.should_receive(:add_address).and_return(*empty_ids,max + 1)
				remove_ids.each do |id|
					Base.api.should_receive(:set_select_address).with(id).ordered
					Base.api.should_receive(:del_address)
				end
				Address.get_empty_ids.should eql(empty_ids)
			end
		end				

		describe ".init" do
			before(:each) do
				Base.stub(:init)
			end

			it "calls Base.init" do
				Base.should_receive(:init)
				Address.init
			end
		end

		describe ".refresh" do
			before(:each) do
				Base.stub(:refresh)
			end

			it "calls Base.refresh" do
				Base.should_receive(:refresh)
				Address.refresh
			end
		end



		describe ".init_by_export" do
			before(:each) do
				Base.api = double('api')
				@file_exported = 'spec/fixtures/files/vs-exported.txt'
				@num_address = File.read(@file_exported).split("\n").size - 1
				@num_attach = 3
				@list = []
				@num_address.times do |idx|
					adr = double('Address').as_null_object
					adr.stub(:update_local_id).and_return(true)
					@list << adr
				end
			end
			it "sets up Address.pool" do
				Base.should_receive(:current?).and_return(true)
				Base.should_receive(:export).and_return(@file_exported)
				# Base.api.should_receive(:get_address_count).and_return(@num_address)
				Address.should_receive(:get_empty_ids).once.and_return([10])
				Address.should_receive(:from_line).and_return(*@list)
				# Base.api.should_receive(:set_select_address).exactly(@num_address).and_return(nil)
				# Base.api.should_receive(:set_select_address)
				# Base.api.should_receive(:set_address_data)
				# Base.api.should_receive(:get_address_data)				
				Base.should_receive(:file_save)
				Address.init_by_export
			end
		end

		describe "#all" do
			before(:each) do
				Address.clean
				Address.api = double('api')
				10.times do |idx|
					Address.api.stub(:create_address).and_return(idx)
					Address.create(:name => 'point-' + idx.to_s, :locate => [idx * 100,  idx * 400] )
				end
			end
			it "returns all addresses" do
				Address.all.size.should == 10
			end
		end

		describe "#create" do
			before(:each) do
				Address.api = double('api')
			end

			it "sends a api_command" do
				id = 100
				name = "point-1"
				locate = [100.01, 200.01]
				Address.api.stub(:create_address).and_return(id)
				obj = Address.create(:name => name, :locate => locate)
				obj.id.should == id
				obj.name.should == name
				obj.locate.should == locate
			end
		end

		describe "#local_id" do
			let(:addr) { Address.new }
			it "with empty data" do
				addr.data = ""
				addr.local_id.should be_nil
			end			
			it "with valid data" do
				addr.data = "<ID:59> hello world"
				addr.local_id.should eql(59)
			end			
			it "with invalid data" do
				addr.data = "hello world"
				addr.local_id.should be_nil
			end			
		end

		describe "#local_id=" do
			let(:addr) { Address.new }
			it "with empty data" do
				addr.data = ""
				addr.local_id = 59
				addr.data.should eql("<ID:59>")
			end
			it "with nil data" do
				addr.data = nil
				addr.local_id = 59
				addr.data.should eql("<ID:59>")
			end

			it "with existing text data" do
				addr.data = "hello world"
				addr.local_id = 59
				addr.data.should eql("<ID:59>hello world")
			end

			it "with existing ID" do
				addr.data = "<ID:101>"
				addr.local_id = 59
				addr.data.should eql("<ID:59>")
			end

			it "with existing ID and text data" do
				addr.data = "<ID:101> hello world"
				addr.local_id = 59
				addr.data.should eql("<ID:59> hello world")
			end
		end

		describe "#find_by_id" do
			before(:each) do
				Address.clean
				adr = Address.new
				adr.id = 0
				Address.pool << adr
			end
			it "find instance of Address" do
				Address.find_by_id(0).should be_an_instance_of(Address)
			end
		end

		describe "#find_by_name" do
			before(:each) do
				Address.clean
				adr = Address.new
				adr.id = 0
				adr.name = "chitech@002-crop-inf"
				Address.pool << adr
			end
			it "returns instance of Address" do
				Address.find_by_name("chitech@002-crop-info").should be_an_instance_of(Address)
			end

			it "returns nil when no match" do
				Address.find_by_name("h").should be_nil
			end

		end

		describe ".find_or_create_by_name" do
			before(:each) do
				Address.clean
				adr = Address.new
				adr.id = 0
				adr.name = "hello"
				Address.pool << adr
			end
			it "returns instance of Address" do
				Address.find_or_create_by_name("hello").should be_an_instance_of(Address)
			end

			it "creates instance of Address" do
				Address.should_receive(:create).with(:name => "h").and_return(Address.new)
				Address.find_or_create_by_name("h").should be_an_instance_of(Address)
			end

		end

		describe "#find_all_by_name" do
			before(:each) do
				Address.clean
				adr = Address.new
				adr.id = 0
				adr.name = "hello"
				Address.pool << adr
				adr = Address.new
				adr.id = 1
				adr.name = "hello"
				Address.pool << adr
				adr = Address.new
				adr.id = 2
				adr.name = "world"
				Address.pool << adr
			end
			it "returns array of instance of Address" do
				adrs = Address.find_all_by_name("bbb")
				adrs.should be_an_instance_of(Array)
			end
		end

		describe "#find_all_attach" do
			let(:adr) { Address.new }
			before(:each) do
				3.times do |idx|
					attach = Attach.new(:name => "file-#{idx}")
					attach.id = idx
					adr.attach_pool << attach
				end
				adr.should_receive(:refresh)
			end
			it "returns array of instance of Attach" do
				ats = adr.find_attach_all
				ats.should be_an_instance_of(Array)
			end
		end

		describe "#find_attach_by_id" do
			let(:adr) { Address.new }
			before(:each) do
				3.times do |idx|
					attach = Attach.new(:name => "file-#{idx}")
					attach.id = idx
					adr.attach_pool << attach
				end
				adr.should_receive(:refresh)
			end
			it "returns instance of Attach" do
				ats = adr.find_attach_by_id(1)
				ats.should be_an_instance_of(Attach)
			end
		end

		describe "#find_attach_by_name" do
			let(:adr) { Address.new }
			before(:each) do
				3.times do |idx|
					attach = Attach.new(:name => "chitech@002-crop-inf")
					attach.id = idx
					adr.attach_pool << attach
				end
				adr.should_receive(:refresh)
			end
			it "returns instance of Attach" do
				ats = adr.find_attach_by_name("chitech@002-crop-info")
				ats.should be_an_instance_of(Attach)
			end
		end

		describe "#find_attach_by_file" do
			let(:adr) { Address.new }
			before(:each) do
				3.times do |idx|
					attach = Attach.new(:name => "file-#{idx}", :file => "file.jpg")
					attach.id = idx
					adr.attach_pool << attach
				end
				adr.should_receive(:refresh)
			end
			it "returns instance of Attach" do
				ats = adr.find_attach_by_file("file.jpg")
				ats.should be_an_instance_of(Attach)
			end
		end

		describe ".find_or_create_attach" do
			let(:adr) { Address.new }
			before(:each) do
				3.times do |idx|
					attach = Attach.new(:name => "file.jpg", :file => "file.jpg")
					attach.id = idx
					adr.attach_pool << attach
				end
				adr.id = 100
				adr.should_receive(:refresh)				
			end

			it "returns instance of Address" do
				adr.find_or_create_attach("tmp/file.jpg").should be_an_instance_of(Attach)
			end

			it "creates instance of Address" do
				Attach.should_receive(:create).with("hello.txt", :name => "hello.txt", :file => "hello.txt", :address_id => adr.id).and_return(Attach.new)
				adr.find_or_create_attach("hello.txt").should be_an_instance_of(Attach)
			end

		end


		describe ".find_or_create_attach_by_name" do
			let(:adr) { Address.new }
			before(:each) do
				3.times do |idx|
					attach = Attach.new(:name => "file-#{idx}", :file => "file.jpg")
					attach.id = idx
					adr.attach_pool << attach
				end
				adr.id = 100
				adr.should_receive(:refresh)
			end

			it "returns instance of Address" do
				adr.find_or_create_attach_by_name("file-1", "hello.txt").should be_an_instance_of(Attach)
			end

			it "creates instance of Address" do
				Attach.should_receive(:create).with("hello.txt", :name => "h", :address_id => adr.id).and_return(Attach.new)
				adr.find_or_create_attach_by_name("h", "hello.txt").should be_an_instance_of(Attach)
			end

		end

		describe "#get_empty_attach_ids", :current => true do
			let(:adr) { Address.new }
			before(:each) do
				Base.api = double('api')
			end
			it "returns empty_attach_ids" do
				attach_ids = [0]
				if attach_ids.empty?
					max = 0
				else
					max = attach_ids.max
				end
				full_ids = (0..max).to_a
				empty_ids = full_ids - attach_ids
				remove_ids = empty_ids.dup
				remove_ids << max + 1
				attach_count = attach_ids.count
				Base.api.should_receive(:get_attach_count).and_return(attach_count)
				Base.api.should_receive(:add_attach_file).and_return(*empty_ids,max + 1)
				remove_ids.each do |id|
					Base.api.should_receive(:set_select_attach).with(id).ordered
					Base.api.should_receive(:del_attach)
				end
				adr.get_empty_attach_ids.should eql(empty_ids)
			end
		end				

		describe "#init_attach_pool", :current => true do
			let(:adr) { Address.new }
			before(:each) do
				@address_id = 67
				adr.id = @address_id
				Base.api = double('api')
				Base.api.stub(:set_select_address).with(@address_id).and_return(true)
				Base.api.stub(:get_attach_count).and_return(0)
			end

			it "call api.set_select_address with id" do
				Base.api.should_receive(:set_select_address).with(@address_id).and_return(true)
				adr.init_attach_pool
			end

			it "does something" do
				adr.init_attach_pool
			end
		end


	end
end