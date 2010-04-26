# PanelPreferencesController.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 26.04.10.

class PanelPreferencesController < NSWindowController
	
	attr_accessor :x, :y, :width, :alignment, :height, :backgroundColor
	
	def initWithController(controller)
		if initWithWindowNibName("PanelPreferences")
			@controller = controller
			NSColorPanel.sharedColorPanel.setShowsAlpha(true)
			window.orderOut(self)
			return self
		end
	end
	
	def editModeStopped
		window.close
		
		fontPanel = NSFontManager.sharedFontManager.fontPanel(false)
		fontPanel.close if fontPanel
		
		NSColorPanel.sharedColorPanel.close if NSColorPanel.sharedColorPanelExists
		
		return true
	end
	
	def windowDidLoad
#		NSLog("X: #{@x}, bgC: #{@backgroundColor}")
	end
	
	def gainedFocus(panelController)
#		NSLog("gained Focus: #{panelController.description}")
		@activePanelController = panelController
		
		windowFrameChanged(panelController)
		@backgroundColor.setColor(@activePanelController.window.backgroundColor)
		@alignment.selectItemWithTag(@activePanelController.textView.alignment)
		
		window.orderFront(self)
	end
	
	def	windowFrameChanged(controller)
		@x.setFloatValue(@activePanelController.window.frame.origin.x)
		@y.setFloatValue(@activePanelController.window.frame.origin.y)
		@width.setFloatValue(@activePanelController.window.frame.size.width)
		@height.setFloatValue(@activePanelController.window.frame.size.height)
	end
	
	def lostFocus(panelController)
#		NSLog("lost Focus: #{panelController.description}")
		window.orderOut(self)
		@activePanelController = nil if panelController == @activePanelController
	end
	
	def frameChanged(sender)
		@activePanelController.window.setFrame([@x.floatValue, @y.floatValue, @width.floatValue, @height.floatValue], display:false)
	end
	
	def	alignmentChanged(sender)
		@activePanelController.textView.setAlignment(@alignment.selectedItem.tag)
	end
	
	def showFonts(sender)
		@activePanelController.window.makeKeyWindow
		NSFontManager.sharedFontManager.orderFrontFontPanel(sender)
	end
	
	def	showColors(sender)
		@activePanelController.window.makeKeyWindow
		NSColorPanel.sharedColorPanel.orderFront(self)
	end
	
	def backgroundColorChanged(sender)
		@activePanelController.window.setBackgroundColor(@backgroundColor.color)
	end
	
end
