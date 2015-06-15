Feature: user starts app

  	As a user
	I want to start an app
	So that I can get an console

	Scenario: start app
		Given I am not yet playing
		Given I have a empty directory "Dhofar 132"
		Given I have a VisualStage data "Dhofar 132/BCG12"
		And I can start VisualStage
		And I can open "Dhofar 132/BCG12"
		Given there are the following files:
			|path						|imag	|locate_x	|locate_y	|size_x		|size_y		|
			|Dhofar 132/data/chitech@002.tif	|52		|100.2		|400.3		|2400.00 	|1800.007	|
			|Dhofar 132/data/chitech@003.tif	|52		|500.2		|400.3		|2400.00 	|1800.007	|
			|Dhofar 132/data/chitech@004.tif	|52		|500.2		|400.3		|2400.00 	|1800.007	|
			|Dhofar 132/data/chitech@005.tif	|52		|500.2		|400.3		|2400.00 	|1800.007	|
			|Dhofar 132/data/chitech@006.tif	|52		|500.2		|400.3		|2400.00 	|1800.007	|				
		When I start a new app
		And I can Address.refresh
		And I can addr.find_or_create_attach_by_name with name "sem-data" and path "Dhofar 132/data/chitech@002.tif"
		And I can addr.find_or_create_attach_by_name with name "sem-data" and path "Dhofar 132/data/chitech@003.tif"		
		And I can addr.find_or_create_attach_by_name with name "sem-data" and path "Dhofar 132/data/chitech@004.tif"		
		And I can addr.find_or_create_attach_by_name with name "sem-data" and path "Dhofar 132/data/chitech@005.tif"		
		And I can addr.find_or_create_attach_by_name with name "sem-data" and path "Dhofar 132/data/chitech@006.tif"				
		And I can addr.find_or_create_attach_by_name with name "sem-data" and path "Dhofar 132/data/chitech@004.tif"				
		And I can refresh app
		And I can Address.find_all_by_name with "sem-data"
		And I can refresh app
		And I can refresh app		
		And I can close
		And I can stop VisualStage

		
