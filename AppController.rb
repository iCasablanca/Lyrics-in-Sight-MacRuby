# AppController.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require "ITunesNotifier"
require "PanelController"
require "NotifierFactory"

class AppController
	
	def init
		if super
			@inEditMode = false
			# enum:
			@quit_lyrics_in_sight_menu_item = 0
			@edit_mode_menu_item = 1
			@add_panel_menu_item = 2
			# UserDefaults key
			@LiSPanelControllers = "PanelControllers"
			self
		end
	end
	
	def createStatusItem
		@statusItem = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)
		@statusItem.setImage(NSImage.imageNamed("menubaricon"))
		@statusItem.setHighlightMode(true)
		@statusItem.setTitle("")
		@statusItem.setEnabled(true)
		@statusItem.setToolTip("")
		
		menu = NSMenu.alloc.initWithTitle("")
		addPanelMenu = NSMenu.alloc.initWithTitle("")
		NotifierFactory.validTypes.each do |typeName|
			item = NSMenuItem.alloc.initWithTitle(typeName,
																						action: :"addPanel:",
																						keyEquivalent: "")
			item.setTarget(self)
		 	item.setTag(@add_panel_menu_item)
			addPanelMenu.addItem(item)
		end
		item = NSMenuItem.alloc.initWithTitle("Add Panel",
																					action: nil,
																					keyEquivalent: "")
		menu.addItem(item)
		menu.setSubmenu(addPanelMenu, forItem: item)
		
		item = NSMenuItem.alloc.initWithTitle("Edit Panels",
																					action: :"switchEditMode",
																					keyEquivalent: "")
		item.setTarget(self)
		item.setTag(@edit_mode_menu_item)
		menu.addItem(item)
		
		item = NSMenuItem.alloc.initWithTitle("Quit Lyrics in Sight",
																					action: :"terminate:",
																					keyEquivalent: "")
		item.setTag(@quit_lyrics_in_sight_menu_item)
		menu.addItem(item)
		
		@statusItem.setMenu(menu)
	end
	
	def createPanels
		@panelControllers.each do |controller|
			controller.showWindow(self)
		end
	end
	
	def registerUserDefaults
		defaultValues = NSMutableDictionary.new
		defaultValues.setObject([], forKey: @LiSPanelControllers)
		NSUserDefaults.standardUserDefaults.registerDefaults(defaultValues)
	end
	
	def loadUserDefaults
		defaults = NSUserDefaults.standardUserDefaults
		@panelControllers = []
		defaults.objectForKey(@LiSPanelControllers).each do |dict|
			@panelControllers.addObject(PanelController.alloc.initWithControllerAndDictionary(self,dict))
		end
	end
	
	def saveUserDefaults
		defaults = NSUserDefaults.standardUserDefaults
		panelControllerAsDictionary = NSMutableArray.alloc.initWithCapacity(@panelControllers.count)
		@panelControllers.each do |controller|
			panelControllerAsDictionary.addObject(controller.dictionary)
		end
		defaults.setObject(panelControllerAsDictionary,
											 forKey: @LiSPanelControllers)
	end
	
	def switchEditMode
		if @inEditMode # switch to normal mode
			setEditMode(false)
		else # switch to edit mode
			setEditMode(true)
		end
	end
	
	def setEditMode(setToEditMode)
		if @inEditMode == setToEditMode
			return
		end
		if setToEditMode
			@panelControllers.each do |controller|
				controller.editModeStarted
			end
			@statusItem.menu.itemWithTag(@edit_mode_menu_item).setState(NSOnState)
			@inEditMode = true
		else
			@panelControllers.each do |controller|
				controller.editModeStopped
			end
			@statusItem.menu.itemWithTag(@edit_mode_menu_item).setState(NSOffState)
			saveUserDefaults # save user defaults after finished edit mode
			@inEditMode = false
		end
	end
	
	def addPanel(sender)
		controller = PanelController.alloc.initWithControllerAndType(self, sender.title)
		@panelControllers.addObject(controller)
		controller.showWindow(self)
		if !@inEditMode
			setEditMode(true)
		else
			controller.editModeStarted()
		end
		
		# save change to user defaults
		saveUserDefaults
	end
	
	def removePanel(controller)
		@panelControllers.removeObject(controller)
		
		#save change to user defaults
		saveUserDefaults
	end
	
end
