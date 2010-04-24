# NotifierFactory.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require "ITunesNotifier"

class NotifierFactory
	
	def self.getNotifierForPanelController(controller)
		type = controller.type
		if type == "iTunes"
			return ITunesNotifier.instance
		else		
			return nil
		end
	end
	
	def self.validTypes
		["iTunes"]
	end
	
end