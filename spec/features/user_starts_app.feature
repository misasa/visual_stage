Feature: user starts app

  	As a user
	I want to start an app
	So that I can get an console

	Scenario: start app
		Given I am not yet playing
		Given I have a empty directory "tmp"		
		Given I have a VisualStage data "tmp/BCG12"
		And I can start VisualStage
		And I can open "tmp/BCG12"
		And I can Address.find_by_id with 12		
		And I can save
		And I can close
		And I can stop VisualStage