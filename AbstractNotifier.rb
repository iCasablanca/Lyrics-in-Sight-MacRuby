# AbstractNotifier.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class	AbstractNotifier
	
	def init
		if super
			@panelControllers = []
			self
		end
	end
	
	def registerPanelController(controller)
		@panelControllers.addObject(controller)
	end
	
	def unregisterPanelController(controller)
		@panelControllers.removeObject(controller)
	end
	
	def requestUpdate(controller)
		NSAssert(false, "Method requestUpdate of abstract class AbstractNotifier called")
	end
	
end
