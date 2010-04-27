# TextView.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Sebastian Albers on 27.04.10.

class TextView < NSTextView

def performKeyEquivalent(event)
	if (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask
		# command key is the only modifier key being pressed
		if event.charactersIgnoringModifiers == "a"
			return NSApp.sendAction(:"selectAll:", to:self.window.firstResponder, from: self)
		elsif event.charactersIgnoringModifiers == "c"
			return NSApp.sendAction(:"copy:", to:self.window.firstResponder, from: self)
		elsif event.charactersIgnoringModifiers == "x"
			return NSApp.sendAction(:"cut:", to:self.window.firstResponder, from: self)
		elsif event.charactersIgnoringModifiers == "v"
			return NSApp.sendAction(:"paste:", to:self.window.firstResponder, from: self)
		end
	end
	return super(event)
end

end
