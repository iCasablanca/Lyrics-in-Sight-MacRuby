# ITunesNotifier.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'singleton'
require 'AbstractNotifier'
require 'LyricsFinder'
framework 'ScriptingBridge'

class	ITunesNotifier < AbstractNotifier
	include Singleton
	
	def init
		if super
			NSDistributedNotificationCenter.defaultCenter.addObserver(self,
																																selector: :"songChanged:",
																																name: "com.apple.iTunes.playerInfo",
																																object: nil)
			load_bridge_support_file NSBundle.mainBundle.resourcePath + "/ITunes.bridgesupport"
			@iTunes = SBApplication.applicationWithBundleIdentifier("com.apple.iTunes")
			@userInfo = nil
			@whitespaceCharacters = NSCharacterSet.characterSetWithCharactersInString(" \t")
			self
		end
	end
	
	def songChanged(notification)
		@userInfo = notification.userInfo.mutableCopy
		
		if @iTunes.currentTrack != nil
			@userInfo["Lyrics"] = lyricsOfTrack(@iTunes.currentTrack)
		end
		
		@panelControllers.each do |controller|
			controller.update(@userInfo)
		end
	end
	
	def requestUpdate(controller)
		if @userInfo == nil
			@userInfo = Hash.new
			if @iTunes.isRunning
				case @iTunes.playerState
				when ITunesEPlSStopped
					@userInfo["Player State"] = "Stopped"
				when ITunesEPlSPlaying
					@userInfo["Player State"] = "Playing"
				when ITunesEPlSPaused
					@userInfo["Player State"] = "Paused"
				when ITunesEPlSFastForwarding
					@userInfo["Player State"] = "Fast Forwarding"
				when ITunesEPlSRewinding
					@userInfo["Player State"] = "Rewinding"
				else
					NSLog("Player State not found")
				end

				currentTrack = @iTunes.currentTrack
				if currentTrack != nil
					@userInfo["Album"] = currentTrack.album
					@userInfo["Album Artist"] = currentTrack.albumArtist
					@userInfo["Album Rating"] = currentTrack.albumRating
					@userInfo["Artist"] = currentTrack.artist
					@userInfo["Artwork Count"] = currentTrack.artworks.count
					@userInfo["Compilation"] = currentTrack.compilation
					@userInfo["Composer"] = currentTrack.composer
					@userInfo["Description"] = currentTrack.objectDescription
					@userInfo["Disc Count"] = currentTrack.discCount
					@userInfo["Disc Number"] = currentTrack.discNumber
					@userInfo["GaplessAlbum"] = currentTrack.gapless
					@userInfo["Genre"] = currentTrack.genre
					@userInfo["Grouping"] = currentTrack.grouping
					@userInfo["Name"] = currentTrack.name
					@userInfo["PersistentID"] = currentTrack.persistentID
					@userInfo["Play Count"] = currentTrack.playedCount
					@userInfo["Play Date"] = currentTrack.playedDate
					@userInfo["Rating Computed"] = currentTrack.rating
					@userInfo["Skip Count"] = currentTrack.skippedCount
					@userInfo["Skip Date"] = currentTrack.skippedDate
					@userInfo["Total Time"] = currentTrack.duration * 1000
					@userInfo["Track Count"] = currentTrack.trackCount
					@userInfo["Track Number"] = currentTrack.trackNumber
					@userInfo["Year"] = currentTrack.year
					@userInfo["Lyrics"] = lyricsOfTrack(currentTrack)
				end # currentTrack != nil
			end # @iTunes.isRunning
		end # @userInfo == nil
		controller.update(@userInfo)
	end
	
	def lyricsOfTrack(track)
		lyrics = track.lyrics
		if lyrics == nil
			lyrics = ""
		end
		
		if lyrics == ""
			lyrics = LyricsFinder.instance.findLyricsOf(track.name, by:track.artist)
			## uncomment the following line to automatically set lyrics of song, if found
			# if lyrics != "" # set lyrics of song via iTunes 
			# @iTunes.currentTrack.setLyrics(lyrics)
			# end
		end
		
		if lyrics != ""
			lyrics = lyrics.gsub("\r\n", "\n")  # replace new line by line feed
			lyrics = lyrics.gsub("\r", "\n")    # replace carriage return by line feed
			lyrics = lyrics.split("\n").collect{|line| line.strip }.join("\n") # trim each line
		end
		
		lyrics
	end
	
end
