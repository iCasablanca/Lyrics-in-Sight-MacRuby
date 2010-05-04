# Panel.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 26.04.10.

class Panel < NSPanel
	
	def awakeFromNib
		NSApplication.sharedApplication.addWindowsItem( self,
																						 title: self.title,
																					filename: false)
	end
	
	def initialize
		setHidesOnDeactive(false)
	end
	
	def canBecomeMainWindow
		return true
	end
	
	def isExcludedFromWindowsMenu
		return false
	end
	
end
