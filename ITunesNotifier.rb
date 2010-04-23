# ITunesNotifier.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'singleton'
require "AbstractNotifier"
framework 'ScriptingBridge'

class	ITunesNotifier < AbstractNotifier
	include Singleton
	
	def init
		if super
			NSDistributedNotificationCenter.defaultCenter.addObserver(self,
																																selector: :"songChanged:",
																																name: "com.apple.iTunes.playerInfo",
																																object: nil)
			path = NSBundle.mainBundle.resourcePath.mutableCopy << "/ITunes.bridgesupport"
			load_bridge_support_file path
			@iTunes = SBApplication.applicationWithBundleIdentifier("com.apple.iTunes")
			@userInfo = nil
			@whitespaceCharacters = NSCharacterSet.characterSetWithCharactersInString(" \t")
			self
		end
	end
	
	def songChanged(notification)
		songInfo = notification.userInfo
		@userInfo = songInfo.mutableCopy
		
		if @iTunes.currentTrack != nil
			@userInfo.setObject(lyricsOfTrack(@iTunes.currentTrack), forKey: "Lyrics")
		end
		
		@panelControllers.each do |controller|
			controller.update(@userInfo)
		end
	end
	
	def requestUpdate(controller)
		if @userInfo == nil
			@userInfo = NSMutableDictionary.new
			state = @iTunes.playerState
			case state
			when ITunesEPlSStopped
				@userInfo.setObject("Stopped", forKey: "Player State")
			when ITunesEPlSPlaying
				@userInfo.setObject("Playing", forKey: "Player State")
			when ITunesEPlSPaused
				@userInfo.setObject("Paused", forKey: "Player State")
			when ITunesEPlSFastForwarding
				@userInfo.setObject("Fast Forwarding", forKey: "Player State")
			when ITunesEPlSRewinding
				@userInfo.setObject("Rewinding", forKey: "Player State")
			else
				NSLog("Player State not found")
			end
			
			# TODO: finish
		end
		controller.update(@userInfo)
	end
	
	def lyricsOfTrack(track)
		NSLog("track: #{track}")
		lyrics = track.lyrics
		if lyrics == nil
			lyrics = ""
		end
		
		if lyrics == ""
			# TODO find lyrics
		end
		lyrics
	end
	
end
