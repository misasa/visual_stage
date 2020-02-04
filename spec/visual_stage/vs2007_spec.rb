require 'spec_helper'

module VisualStage
	describe VS2007 do
		before(:each) do
#			Address.pool << Address.new(:name => 'hello')
		end

		describe ".start" do
			before(:each) do
				@pid = 1000
				VS2007.stub(:get_stdout).with(VS2007.exe_path + ' ' + "start").and_return("SUCCESS #{@pid}")				
				VS2007.stub(:pid).and_return(@pid)
			end
			it "call exe with start" do
				VS2007.should_receive(:get_stdout).with(VS2007.exe_path + ' ' + "start")
				VS2007.start()
			end

			#it "call pid" do
			#	VS2007.should_receive(:pid).at_least(1).and_return(@pid)
			#	VS2007.start()
			#end

			it "returns SUCCESS PID with pid" do
				r = VS2007.start()
				r.should eql("SUCCESS #{@pid}")
			end

			it "returns FAILED without pid" do
#				VS2007.stub(:pid).and_return(nil)				
				VS2007.stub(:get_stdout).with(VS2007.exe_path + ' ' + "start").and_return("")				
				r = VS2007.start()
				r.should eql("FAILED")				
			end
		end

		describe ".stop" do
			before(:each) do
			end
			it "call exe with stop" do
				VS2007.should_receive(:get_stdout).with(VS2007.exe_path + ' ' + "stop")
				VS2007.stop
			end
		end

		describe ".status" do
			before(:each) do
			end
			it "call exe with status" do
				VS2007.should_receive(:get_stdout).with(VS2007.exe_path + ' ' + "status")
				VS2007.status
			end
		end

		describe ".pid" do
			before(:each) do
				VS2007.pid = nil
				@pid = 1000
			end

			context "with pid" do
				before do
					VS2007.pid = @pid
				end
				it "calls status" do
					VS2007.should_not_receive(:status)
					VS2007.pid
				end	
				after do
					VS2007.pid = nil
				end
			end	
			it "calls status" do
				VS2007.should_receive(:status).and_return("RUNNING #{@pid}")
				VS2007.pid
			end

			it "returns pid when status is running" do
				VS2007.stub(:status).and_return("RUNNING #{@pid}")
				VS2007.pid.should eql(@pid)
			end

			it "returns nil when status is stopped" do
				VS2007.stub(:status).and_return("STOPPED")
				VS2007.pid.should be_nil
			end

		end

		describe ".is_running?" do
			it "calls pid" do
				VS2007.should_receive(:pid).and_return(1000)
				VS2007.is_running?
			end

			it "returns true when pid is not null" do
				VS2007.stub(:pid).and_return(1000)
				VS2007.is_running?.should be_true
			end

			it "returns false when pid is null" do
				VS2007.stub(:pid).and_return(nil)
				VS2007.is_running?.should be_false
			end
		end

		describe ".is_stopped?" do
			it "calls is_running?" do
				VS2007.should_receive(:is_running?)
				VS2007.is_stopped?
			end

			it "returns true when is_running? is false" do
				VS2007.stub(:is_running?).and_return(false)
				VS2007.is_stopped?.should be_true
			end

			it "returns false when is_running? is true" do
				VS2007.stub(:is_running?).and_return(true)
				VS2007.is_stopped?.should be_false
			end
		end

	end
end