require 'spec_helper'

module VisualStage
	describe Base do
		before(:each) do
#			Address.pool << Address.new(:name => 'hello')
			Base.clean
			#Base.api = VS2007API.new(:verbose => true)
			Base.api = double('api')
		end

		describe ".open" do
			before(:each) do
				@dirname = "C:/VS2007data/test"
				Base.api = double('api')
				Base.api.stub(:open)
				Base.stub(:data_dir=)
				Base.stub(:load_data)				
			end

			it "calls api.open" do
				Base.api.should_receive(:open).with(@dirname)
				Base.should_receive(:load_data)
				Base.open(@dirname)
			end

			it "calls .data_dir= with dirname" do
				Base.should_receive(:data_dir=).with(@dirname)
				Base.open(@dirname)
			end

		end

		describe ".close" do
			before(:each) do
				@dirname = "C:/VS2007data/test"
				Base.api = double('api')
				Base.api.stub(:file_close)
				#Base.stub(:data_dir=)				
			end

			it "calls api.close_file" do
				Base.api.should_receive(:file_close).with("NO")
				Base.close
			end

			it "set @@data_dir as nil" do
				#Base.should_receive(:data_dir=).with(nil)
				Base.close
				Base.data_dir.should be_nil
			end

		end


		describe ".is_netpath?" do
			before(:each) do
				@filename = '0003_00.abcdefg.txt'
				@local_dir = 'Y:/yyachi/GrtCCG07'
				@local_path = File.join(@local_dir, @filename)
				@net_dir = "//vs-data.misasa.okayama-u.ac.jp/VS2007data/yyachi/GrtCCG07"
				@net_path = File.join(@net_dir, @filename)
				@net_path_windows = @net_path.gsub(/\//,'\\')
			end

			it "returns true with net_path (//xxx)" do
				Base.is_netpath?(@net_path).should be_true
			end

			it "returns true with net_path (\\\\xxx)" do
				Base.is_netpath?(@net_path).should be_true
			end

			it "returns false with local_path" do
				Base.is_netpath?(@local_path).should be_false
			end

		end

		describe ".netpath" do
			before(:each) do
				@filename = '0003_00.abcdefg.txt'
				@local_dir = 'Y:/yyachi/GrtCCG07'
				@local_path = File.join(@local_dir, @filename)
				#@local_net_dir = 'Y:\\yyachi\\GrtCCG07'
				@net_dir = "//vs-data.misasa.okayama-u.ac.jp/VS2007data/yyachi/GrtCCG07"
				@net_path = File.join(@net_dir, @filename)
				#@local_path = File.join(@local_dir, @filename)
			end
			
			# it "returns local_path with net_path" do
			# 	Base.netpath(@net_path).should eql(@local_path)
			# end

			# it "returns net_path with local_path" do
			# 	Base.netpath(@local_path).should eql(@net_path)
			# end
		end

		describe ".myexpand_path" do
			before(:each) do
				@filename = '0003_00.abcdefg.txt'
				@local_dir = 'Y:/yyachi/GrtCCG07'
				@local_path = File.join(@local_dir, @filename)
				#@local_net_dir = 'Y:\\yyachi\\GrtCCG07'
				@net_dir = "//vs-data.misasa.okayama-u.ac.jp/VS2007data/yyachi/GrtCCG07"
				@net_path = File.join(@net_dir, @filename)
				#@local_path = File.join(@local_dir, @filename)
			end
			
			it "returns local_path with local_path" do
				Base.myexpand_path(@local_path).should eql(@local_path)
			end

			# it "returns local_path with net_path" do
			# 	Base.myexpand_path(@net_path).should eql(@local_path)
			# end
		end

		describe ".get_data_dir" do
			before(:each) do
				# @marker = 'Rrtgkdo'
				# @local_dir = 'C:\\VS2007data\\vsattach'
				# @local_dir_m = @local_dir.gsub(/\\/,'/')
				# @local_path = File.join(@local_dir, '0003_00.' + @marker.downcase + '.txt')
				# @local_path_m = File.join(@local_dir_m, '0003_00.' + @marker.downcase + '.txt')				
				# @local_net_dir = 'Y:\\yyachi\\GrtCCG07'
				# @local_net_dir_m = @local_net_dir.gsub(/\\/,'/')				
				# @net_dir = "\\\\vs-data.misasa.okayama-u.ac.jp\\VS2007data\\yyachi\\GrtCCG07"
				# @net_dir_m = @net_dir.gsub(/\\/,'/')
				# @net_path = File.join(@net_dir, '0003_00.' + @marker.downcase + '.txt')
				# @net_path_m = File.join(@net_dir_m, '0003_00.' + @marker.downcase + '.txt')				
				# VS2007Mon.stub(:is_running).and_return(true)
				# VS2007Mon.stub(:start)
				# VS2007Mon.stub(:stop)
				Base.stub(:current?).and_return(true)
				# Base.api = double('api')
				# Base.api.stub(:add_and_remove_tempfile).and_return(@marker)
				# Base.stub(:find_path_from_log).and_return(@local_path)
			end

			# it "starts VS2007Mon if it is not running" do
			# 	VS2007Mon.should_receive(:is_running?).and_return(false)
			# 	VS2007Mon.should_receive(:start)
			# 	Base.get_data_dir		
			# end

			it "returns nil if self.current?" do
				Base.should_receive(:current?).and_return(false)
				Base.get_data_dir.should be_nil
			end

			it "returns path (Y:/) with local_dir (Y:\\xxx)" do
				VS2007.should_receive(:pwd).and_return(@local_path)
#				Base.should_receive(:find_path_from_log).and_return(@local_path)
				Base.get_data_dir.should eql(@local_dir_m)
			end

			# it "returns path (//xxx) with net_dir (\\\\xxx)" do
			# 	Base.should_receive(:find_path_from_log).and_return(@net_path)
			# 	Base.get_data_dir.should eql(@local_net_dir_m)
			# end

			it "returns path (Y:/) with local_dir (Y:/xxx)" do
				VS2007.should_receive(:pwd).and_return(@local_path)
				#Base.should_receive(:find_path_from_log).and_return(@local_path_m)
				Base.get_data_dir.should eql(@local_dir_m)
			end

			# it "returns path (//xxx) with net_dir (//xxx)" do
			# 	Base.should_receive(:find_path_from_log).and_return(@net_path_m)
			# 	Base.get_data_dir.should eql(@local_net_dir_m)
			# end

		end

		describe ".data_dir=" do
			before(:each) do
				@path = "vs2007-data-dir"
				FileTest.stub(:directory?).and_return(true)
			end
			it "check the path" do
				FileTest.should_receive(:directory?).with(@path).and_return(true)
				Base.data_dir = @path
			end

			it "check the path" do
				FileTest.should_receive(:directory?).with(@path).and_return(false)
				proc {
					Base.data_dir = @path
					}.should raise_error
			end

			it "sets data_dir" do
				Base.data_dir = @path
				Base.data_dir.should eql(@path)				
			end
		end

		describe ".load_data_from_file" do
			before(:each) do
				@data_dir = File.expand_path('../../fixtures/data/BCG12',__FILE__)
				@address_dat_path = File.join(@data_dir,"ADDRESS.DAT")

				Base.stub(:data_dir).and_return(@data_dir)
			end

			it "calls .address_dat_path" do
				Base.should_receive(:address_dat_path).at_least(1).and_return(@address_dat_path)
				Base.load_data_from_file
			end
		end

		describe ".load_data" do
			before(:each) do
				@data_dir = File.expand_path('../../fixtures/files',__FILE__)
				#@address_dat_path = File.join(@data_dir,"ADDRESS.DAT")
				@addresslist_path = File.join(@data_dir,"address.txt")
				@attachlist_path = File.join(@data_dir,"attach.txt")
				Base.stub(:current?).and_return(true)
				VS2007.stub(:addresslist)
				VS2007.stub(:attachlist)
			end

			it "calls Base.current?" do
				Base.should_receive(:current?).and_return(true)
				Base.load_data
			end

			it "calls VS2007.addresslist" do
				VS2007.should_receive(:addresslist).and_return(File.read(@addresslist_path))
				#Base.should_receive(:address_dat_path).at_least(1).and_return(@address_dat_path)
				Base.load_data
			end

			it "calls VS2007.attachlist" do
				VS2007.stub(:addresslist).and_return(File.read(@addresslist_path))
				VS2007.should_receive(:attachlist).and_return(File.read(@attachlist_path))
				#Base.should_receive(:address_dat_path).at_least(1).and_return(@address_dat_path)
				Base.load_data
			end
			
		end


		describe ".current?" do
			it "chekcs VS2007.pwd" do
				#Base.api.should_receive(:get_select_address)
				VS2007.should_receive(:pwd)
				Base.current?
			end
		end


		describe "#world2stage" do
			let(:points_on_world){ [100,100] }
			let(:points_on_stage){ [100,100] }			
			it "call chg_world_to_stage" do
				Base.api.should_receive(:chg_world_to_stage).with(points_on_world[0], points_on_world[1]).and_return(points_on_stage)
				points_on_stage = Base.world2stage(points_on_world)
				points_on_stage.size.should eql(2)
			end
		end




		describe "#init" do
			before(:each) do
				# Base.api = double('api')
				# #Base.api.stub(:open).and_return(true)
				# @file_exported = 'spec/fixtures/files/vs-exported.txt'
				# @num_address = File.read(@file_exported).split("\n").size - 1
				# @num_attach = 3
				Base.stub(:current?).and_return(true)
				Base.stub(:get_data_dir).and_return(@data_dir)
				@data_dir = File.expand_path('../../fixtures/data/BCG12',__FILE__)
				@address_dat_path = File.join(@data_dir,"ADDRESS.DAT")
				Base.stub(:data_dir).and_return(@data_dir)
				Base.stub(:load_data)	
			end
			it "calls .current?" do
				Base.should_receive(:current?)				
				Base.init
			end

			it "calls .get_data_dir when .data_dir is null" do
				Base.stub(:data_dir).and_return(nil)
				Base.should_receive(:get_data_dir).and_return(@data_dir)
				Base.init
			end

			it "should not calls .get_data_dir when .data_dir is not null" do
				Base.stub(:data_dir).and_return(@data_dir)
				Base.should_not_receive(:get_data_dir)
				Base.init
			end

		end		

		describe "#export" do
			before(:each) do
				#Base.api = double('api')
				#Base.api.stub(:open).and_return(true)
			end
			it "opens visual stage" do
				Base.should_receive(:export).and_return('exported-vs')
				Base.export
			end
		end		

	end
end