# AppDelegate.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'AppController'

class AppDelegate
	
	def applicationDidFinishLaunching(notification)
		@controller = AppController.new
		
		@controller.createStatusItem
		@controller.registerUserDefaults
		@controller.loadUserDefaults
		@controller.createPanels
	end
	
	def applicationShouldTerminate(application)
		@controller.setEditMode(false)
		@controller.saveUserDefaults
		NSTerminateNow
	end
	
end
