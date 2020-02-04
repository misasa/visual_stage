require 'spec_helper'

module VisualStage
	describe VS2007API do
		before(:each) do
#			Address.pool << Address.new(:name => 'hello')
		end
		describe "with vs", :current => true do
			let(:pid){ VS2007.pid}
			let(:api){ VS2007API.new({:pid => pid, :verbose => true}) }
			before do
				VS2007.start
				api
				api.test_cmd
			end
			context "without logging_level" do
				it { expect(1).to eql(1)}
			end
			context "with logging_level INFO" do
				let(:api){ VS2007API.new({:pid => pid,:logging_level => 'INFO', :verbose => true, :logger => Logger.new(STDERR)}) }
				it { expect(1).to eql(1)}
			end
			after(:each) do
				VS2007.stop
			end
		end

		describe "#cygpath" do
			before(:each) do
				@api = VS2007API.new(:offline => true)
				Open3.stub(:capture3)
			end

			it "convert file_path" do
				Open3.should_receive(:capture3).and_return(['a', 'b', 'c'])
				path = @api.cygpath('tmp/deleteme.d/chitech@002.tif', "d")
				path.should_not be_nil
			end
		end

		describe "#myexpand_path" do
			before(:each) do
				@api = VS2007API.new(:offline => true)
			end

			it "convert file_path" do
				path = @api.myexpand_path('tmp/data/hello.tct')
				path.should_not be_nil
			end
		end

		describe "#open" do
			before(:each) do
				@api = VS2007API.new(:offline => true)
				@api.stub(:exec_command).and_return('SUCCESS')
				@filename = 'hello-vs'
			end
			it "sends file_open" do
				@api.should_receive(:exec_command).with(/FILE_OPEN/)
				#@api.should_receive(:exec_command).with(/hello-vs/).and_return("SUCCESS")
				@api.open(@filename)
			end
		end

		describe "#file_new" do
			before(:each) do
				@api = VS2007API.new(:offline => true)
				@api.stub(:exec_command).and_return('SUCCESS')
				@filename = 'hello-vs'
			end
			it "sends file_new" do
				@api.should_receive(:exec_command).with(/FILE_NEW/)
				#@api.should_receive(:exec_command).with(/hello-vs/).and_return("SUCCESS")
				@api.file_new(@filename)
			end
		end


		describe "#test_cmd" do
			before(:each) do
				#VS2007API.stub(:get_handle).and_return(nil)
				@api = VS2007API.new(:offline => true)
				@api.stub(:get_handle).and_return(1000)
				@api.connect
				#@api.handle = 1000
				@api.stub(:exec_command).and_return(nil)
			end
			it "sends exec_command" do
				@api.should_receive(:exec_command).with(@api.api_exe + " -d #{@api.handle}" + ' "TEST_CMD"')
				@api.test_cmd()
			end
		end

		describe "#create_address" do
			let(:param) { {:name => 'addr-1', :locate => [100.2,200.3]} }
			before(:each) do
				@api = VS2007API.new(:offline => true)
				@address_id = 1
			end
			it "sends exec_command" do
				@api.should_receive(:set_marker_position).with('POINT', param[:locate])
				@api.should_receive(:add_address).and_return(@address_id)
				#@api.should_receive(:get_stdout).with(@api.api_exe + ' ' + "\"SET_MARKER_POSITION POINT,#{param[:locate].join(',')}\"").and_return("SUCCESS")				
#				@api.should_receive(:get_stdout).with(@api.api_exe + " \"SET_ADDRESS_DATA <ID:#{@address_id}>\"").and_return("SUCCESS")
				@api.should_receive(:get_stdout).with(@api.api_exe + " \"SET_ADDRESS_NAME #{param[:name]}\"").and_return("SUCCESS")	
				@api.should_receive(:get_stdout).with(@api.api_exe + " \"SET_ADDRESS_LOCATE #{param[:locate].join(',')}\"").and_return("SUCCESS")	
#				@api.should_receive(:file_save)
#				@api.should_receive(:get_stdout).with(@api.api_exe + ' "ADD_ADDRESS"').and_return("SUCCESS #{@address_id}")				
				@api.create_address(param).should == @address_id
			end
		end

		describe "#get_select_address" do
			before(:each) do
				#VS2007API.stub(:get_handle).and_return(nil)
				@api = VS2007API.new(:offline => true)
				@address_id = 102
			end
			it "sends exec_command" do
				@api.should_receive(:get_stdout).and_return("SUCCESS #{@address_id}")
				@api.add_address().should == @address_id
			end
		end

		describe "#get_attach_default_parameter" do
			let(:api){VS2007API.new(:offline => true)}
			let(:name){'def-1'}
			let(:imag){10.25}
			it "returns parameter" do
				api.should_receive(:get_stdout).with(api.api_exe + ' ' + "\"GET_DEF_ATTACH_NAME\"").and_return("SUCCESS #{name}")
				api.should_receive(:get_stdout).with(api.api_exe + ' ' + "\"GET_DEF_ATTACH_IMAG\"").and_return("SUCCESS #{imag}")
				param = api.get_attach_default_parameter
				param.should include(:name => name)
				param.should include(:imag => imag)
			end
		end

		describe "#set_attach_default_parameter" do
			let(:api){VS2007API.new(:offline => true)}
			let(:name){'set-1'}
			let(:imag){10.25}
			it "sets parameter" do
				api.should_receive(:get_stdout).with(api.api_exe + ' ' + "\"SET_DEF_ATTACH_NAME #{name}\"").and_return("SUCCESS")
				api.should_receive(:get_stdout).with(api.api_exe + ' ' + "\"SET_DEF_ATTACH_IMAG #{imag}\"").and_return("SUCCESS")
				api.set_attach_default_parameter(:name => name, :imag => imag)
			end

		end
		describe "#size2imag" do
			let(:api) {VS2007API.new(:offline => true)}
			let(:osize){[126000.000, 94500.000]}
			let(:size) {[2400, 1800.007]}
			it "returns imag" do
				api.should_receive(:get_ms_image_size).with(1).and_return(osize)
				imag = api.size2imag(size)
			end
		end

		describe "#attach_file" do
			let(:image_path) {"tmp/chitech@002.tif"}
			let(:cpath){ VS2007API.myexpand_path(image_path) }
			let(:def_param) { {:name => 'def-1', :imag => 10} }
			let(:param){ {:name => 'set-1', :locate => [100.2,400.3], :size => [2400.00, 1800.007]} }
			let(:imag) { 52 }
			before(:each) do
				@api = VS2007API.new(:offline => true)
				@attach_id = 0
			end
			it "sends exec_command" do
				@api.should_receive(:size2imag).with(param[:size]).and_return(52)
				@api.should_receive(:get_attach_default_parameter).and_return(def_param)
				@api.should_receive(:set_attach_default_parameter).with(param.merge(:imag => imag))
				@api.should_receive(:get_stdout).with(@api.api_exe + ' ' + "\"SET_MARKER_POSITION POINT,#{param[:locate].join(',')}\"").and_return("SUCCESS")				
				#@api.should_receive(:set_marker_position).with(param[:locate])				
				@api.should_receive(:get_stdout).with(@api.api_exe + ' ' + "\"ADD_ATTACH_FILE #{cpath}\"").and_return("SUCCESS #{@attach_id}")
				@api.should_receive(:set_select_attach).with(@attach_id, 'TRUE')
				@api.should_receive(:get_attach_class).with(@attach_id).and_return(1)
				@api.should_receive(:get_stdout).with(@api.api_exe + ' ' + "\"SET_ATTACH_SIZE #{@attach_id},#{param[:size].join(',')}\"").and_return("SUCCESS")			
				@api.should_receive(:set_attach_center).with(@attach_id, param[:size][0]/2.0, param[:size][1]/2.0)
				#@api.should_receive(:file_save)
				@api.should_receive(:set_attach_default_parameter).with(def_param)
				@api.attach_file(image_path,param).should == @attach_id
			end

		end

		describe "#chg_world_to_stage" do
			let(:points_on_world) {[100.0, -100.0]}
			let(:points_on_stage) {[50.001, -32.456]}

			before(:each) do
				#VS2007API.stub(:get_handle).and_return(nil)
				@api = VS2007API.new(:offline => true)
#				@address_id = 102
			end
			it "sends exec_command" do
				output = "SUCCESS #{points_on_stage.join(',')}"
				@api.should_receive(:get_stdout).and_return(output)
				@api.chg_world_to_stage(points_on_world[0], points_on_world[1]).should == points_on_stage
			end
		end

		describe "#get_address_locate" do
			before(:each) do
				#VS2007API.stub(:get_handle).and_return(nil)
				@api = VS2007API.new(:offline => true)
				@locate = [2000.021, -2345.782]
			end
			it "sends exec_command" do
				@api.should_receive(:get_stdout).and_return("SUCCESS #{@locate.join(',')}")
				@api.get_address_locate().should == @locate
			end
		end



		describe "#str2val" do
			before(:each) do
				#VS2007API.stub(:get_handle).and_return(nil)
				@api = VS2007API.new(:offline => true)
				@str = "109"
			end
			it "with intger return integer" do
#				@api.should_receive(:get_stdout).with(@api.api_exe + ' "TEST_CMD"').and_return("SUCCESS")
				@api.str2val(@str).should == @str.to_i
			end
		end

		describe "#str2val" do
			before(:each) do
				#VS2007API.stub(:get_handle).and_return(nil)
				@api = VS2007API.new(:offline => true)
				@str = "10900.002"
			end
			it "with float return float" do
				@api.str2val(@str).should == @str.to_f
			end
		end

		describe "#str2val" do
			before(:each) do
				#VS2007API.stub(:get_handle).and_return(nil)
				@api = VS2007API.new(:offline => true)
				@str = "@34"
			end
			it "with string return string" do
#				@api.should_receive(:get_stdout).with(@api.api_exe + ' "TEST_CMD"').and_return("SUCCESS")
				@api.str2val(@str).should == @str
			end
		end


	end
end