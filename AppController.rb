# AppController.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'ITunesNotifier'
require 'PanelController'
require 'NotifierFactory'

class AppController

	attr_reader :inEditMode
	
	def initialize
		if super
			@inEditMode = false
			@panelPreferencesController = PanelPreferencesController.alloc.initWithController(self)
			
			# enum:
			@quit_lyrics_in_sight_menu_item = 0
			@edit_mode_menu_item = 1
			@add_panel_menu_item = 2
			@write_lyrics_in_file_menu_item = 3
			# UserDefaults key
			@LiSPanelControllers = "PanelControllers"
			@LiSWriteLyricsInFile = "WriteLyricsInFile"
			return self
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
																					action: :"switchEditMode:",
																					keyEquivalent: "")
		item.setTarget(self)
		item.setTag(@edit_mode_menu_item)
		menu.addItem(item)
		
		item = NSMenuItem.alloc.initWithTitle("Write Lyrics in File",
																					action: :"writeLyricsInFile:",
																					keyEquivalent: "")
		item.setTarget(self)
		item.setTag(@write_lyrics_in_file_menu_item)
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
		defaultValues = {}
		defaultValues[@LiSPanelControllers] = []
		defaultValues[@LiSWriteLyricsInFile] = false
		NSUserDefaults.standardUserDefaults.registerDefaults(defaultValues)
	end
	
	def loadUserDefaults
		defaults = NSUserDefaults.standardUserDefaults
		
		GlobalOptions.instance.setOption(:writeLyricsInFile, defaults[@LiSWriteLyricsInFile])
		
		@statusItem.menu.itemWithTag(@write_lyrics_in_file_menu_item).setState(NSOnState) if defaults[@LiSWriteLyricsInFile]
		@panelControllers = []
		defaults[@LiSPanelControllers].each do |dict|
			@panelControllers.push(PanelController.alloc.initWithControllerAndDictionary(self,dict))
		end
	end
	
	def saveUserDefaults
		defaults = NSUserDefaults.standardUserDefaults
		
		defaults[@LiSWriteLyricsInFile] = GlobalOptions.instance.getOption(:writeLyricsInFile)
		
		panelControllerAsDictionary = []
		@panelControllers.each do |controller|
			panelControllerAsDictionary.push(controller.dictionary)
		end
		defaults[@LiSPanelControllers] = panelControllerAsDictionary
	end
	
	def switchEditMode(sender)
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
			#@panelPreferencesController.showWindow(self)
			@panelControllers.each do |controller|
				@panelPreferencesController.gainedFocus(controller) if controller.window.isMainWindow
				controller.editModeStarted
			end
			@statusItem.menu.itemWithTag(@edit_mode_menu_item).setState(NSOnState)
			@inEditMode = true
		else
			@inEditMode = false
			if @panelPreferencesController.editModeStopped
				@panelControllers.each do |controller|
					controller.editModeStopped
				end
				@statusItem.menu.itemWithTag(@edit_mode_menu_item).setState(NSOffState)
				saveUserDefaults # save user defaults after finished edit mode
			end
		end
	end
	
	def addPanel(sender)
		controller = PanelController.alloc.initWithControllerAndType(self, sender.title)
		@panelControllers.push(controller)
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
		@panelControllers.delete(controller)
		
		#save change to user defaults
		saveUserDefaults
	end
	
	def gainedFocus(panelController)
		@panelPreferencesController.gainedFocus(panelController) if @inEditMode
	end
	
	def lostFocus(panelController)
		@panelPreferencesController.lostFocus(panelController) if @inEditMode
	end
	
	def	windowFrameChanged(panelController)
		@panelPreferencesController.windowFrameChanged(panelController) if @inEditMode
	end
	
	def writeLyricsInFile(sender)		
		oldState = GlobalOptions.instance.getOption(:writeLyricsInFile)
		GlobalOptions.instance.setOption(:writeLyricsInFile, !oldState)
		
		sender.setState(NSOnState)	if !oldState
		sender.setState(NSOffState)	if oldState
	end
	
end
