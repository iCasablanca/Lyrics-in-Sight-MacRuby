# PanelController.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require "AppController"
require "AbstractNotifier"
require "NotifierFactory"
require "FormulaParser"

class	PanelController < NSWindowController

	attr_reader :type
	attr_accessor :textView
	
	def initWithControllerAndType(controller, type)
		if initWithWindowNibName("Panel")
			@controller = controller
			
			setShouldCascadeWindows(false)
			@rect = NSMakeRect(500, 500, 500, 300)
			@type = type
			@formula = "Edit this text"
			@inEditMode = false
			
			@notifier = NotifierFactory.getNotifierForPanelController(self)
			@notifier.registerPanelController(self)
			self
		end
	end
	
	def initWithControllerAndDictionary(controller, dictionary)
		if initWithControllerAndType(controller, dictionary.objectForKey("Type"))
			@formula					= dictionary.objectForKey("Formula")
			@rect.origin.x		= dictionary.objectForKey("X").floatValue
			@rect.origin.y		= dictionary.objectForKey("Y").floatValue
			@rect.size.width	= dictionary.objectForKey("Width").floatValue
			@rect.size.height	= dictionary.objectForKey("Height").floatValue
			self
		end
	end
	
	def dictionary
		dictionary = NSMutableDictionary.new
		dictionary.setObject(@type, forKey: "Type")
		dictionary.setObject(@formula, forKey: "Formula")
		dictionary.setObject(NSNumber.numberWithFloat(@rect.origin.x), forKey: "X")
		dictionary.setObject(NSNumber.numberWithFloat(@rect.origin.y), forKey: "Y")
		dictionary.setObject(NSNumber.numberWithFloat(@rect.size.width), forKey: "Width")
		dictionary.setObject(NSNumber.numberWithFloat(@rect.size.height), forKey: "Height")
		dictionary
	end
	
	def update(userInfo)
		if @inEditMode
			return
		end
		
		if userInfo == nil
			@textView.setString("")
			return
		end
		
		parser = FormulaParser.alloc.initWithDictionary(userInfo)
		@textView.setString(parser.evaluateFormula(@formula))
	end
	
	def editModeStarted
		@inEditMode = true
		
		setEditable(true)
		
		@textView.setString(@formula)
	end
	
	def editModeStopped
		@inEditMode = false
		
		@formula = @textView.string.copy
		@rect = window.frame
		
		setEditable(false)
		
		@notifier.requestUpdate(self)
	end
	
	def setEditable(newState)
		window.setMovable(newState)
		if newState
			window.setStyleMask(window.styleMask | NSClosableWindowMask | NSResizableWindowMask | NSTitledWindowMask | NSUtilityWindowMask)
		else
			window.setStyleMask(window.styleMask & ~NSClosableWindowMask & ~NSResizableWindowMask & ~NSTitledWindowMask & ~NSUtilityWindowMask)
		end
		
		@textView.setEditable(newState)
		@textView.setSelectable(newState)
		if !newState
			@textView.updateInsertionPointStateAndRestartTimer(false)
		end
	end
	
	def windowDidLoad
#		window.setLevel(kCGDesktopIconWindowLevel)
		window.setLevel(CGWindowLevelForKey(2))
		window.setFrame(@rect, display: true, animate: true)
		setEditable(false)
		
		@textView.setTextColor(NSColor.whiteColor)
		
		@notifier.requestUpdate(self)
		
		window.display
	end
	
	def windowWillClose(notification)
		@notifier.unregisterPanelController(self)
		@controller.removePanel(self)
	end
	
	def description
		"PanelController: type = '#{@type}', formula = '#{@formula}', x = #{rect.origin.x}, y = #{rect.origin.y}, width = #{rect.size.width}, height = #{rect.size.height}"
	end
	
end
