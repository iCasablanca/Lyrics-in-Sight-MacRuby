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
			
			currentTrack = @iTunes.currentTrack
			if currentTrack != nil
				@userInfo.setObject(currentTrack.album, forKey: "Album") if currentTrack.album
				@userInfo.setObject(currentTrack.albumArtist, forKey: "Album Artist") if currentTrack.albumArtist
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.albumRating), forKey: "Album Rating")
				@userInfo.setObject(currentTrack.artist, forKey: "Artist") if currentTrack.artist
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.artworks.count), forKey: "Artwork Count")
				@userInfo.setObject(NSNumber.numberWithBool(currentTrack.compilation), forKey: "Compilation")
				@userInfo.setObject(currentTrack.composer, forKey: "Composer") if currentTrack.composer
				@userInfo.setObject(currentTrack.objectDescription, forKey: "Description") if currentTrack.objectDescription
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.discCount), forKey: "Disc Count")
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.discNumber), forKey: "Disc Number")
				@userInfo.setObject(NSNumber.numberWithBool(currentTrack.gapless), forKey: "GaplessAlbum")
				@userInfo.setObject(currentTrack.genre, forKey: "Genre") if currentTrack.genre
				@userInfo.setObject(currentTrack.grouping, forKey: "Grouping") if currentTrack.grouping
				@userInfo.setObject(currentTrack.name, forKey: "Name") if currentTrack.name
				@userInfo.setObject(currentTrack.persistentID, forKey: "PersistentID") if currentTrack.persistentID
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.playedCount), forKey: "Play Count")
				@userInfo.setObject(currentTrack.playedDate, forKey: "Play Date") if currentTrack.playedDate
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.rating), forKey: "Rating Computed")
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.skippedCount), forKey: "Skip Count")
				@userInfo.setObject(currentTrack.skippedDate, forKey: "Skip Date") if currentTrack.skippedDate
				@userInfo.setObject(NSNumber.numberWithDouble(currentTrack.duration * 1000), forKey: "Total Time")
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.trackCount), forKey: "Track Count")
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.trackNumber), forKey: "Track Number")
				@userInfo.setObject(NSNumber.numberWithInt(currentTrack.year), forKey: "Year")
				@userInfo.setObject(lyricsOfTrack(currentTrack), forKey: "Lyrics")
			else
				@userInfo = NSDictionary.new
			end
		end
		controller.update(@userInfo)
	end
	
	def lyricsOfTrack(track)
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
