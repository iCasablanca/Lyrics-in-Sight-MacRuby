# LyricsFinder.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Sebastian Albers on 24.04.10.

require 'singleton'
require 'uri'

class LyricsFinder
	include Singleton
		
	def	findLyricsOf(title, by:artist)
		return "" if title == nil or artist == nil
		baseUrl = "http://lyrics.wikia.com/"
  
    # try to download lyrics with given artist and title
    url = baseUrl + encodeUri(artist) + ":" + encodeUri(title)
		lyrics = downloadLyricsFrom(url)  
    return lyrics unless not lyrics

		# try to download lyrics using given artist and capitalized title
		url = baseUrl + encodeUri(artist) + ":" + encodeUri(title.capitalizedString)
		lyrics = downloadLyricsFrom(url)  
    return lyrics unless not lyrics
		
		# lyrics not found
		return ""
	end
	
	private
	
	def downloadLyricsFrom(url)
		data = NSData.dataWithContentsOfURL( NSURL.URLWithString(url) )
		return nil if data == nil
		
		document = NSXMLDocument.alloc.initWithData(data,
																				options:NSXMLDocumentTidyHTML,
																					error:nil);
		return nil if document == nil;
		
		content = document.stringValue;
		
		if content =~ /You must enable javascript to view this page\. This is a requirement of our licensing agreement with music Gracenote\..*?Ringtone to your Cell (.*?\n.*?)[ ]*\n<p>NewPP limit report/m
			content = $1 # lyrics found -> take first
			if content =~ /You must enable javascript to view this page\. This is a requirement of our licensing agreement with music Gracenote\..*?Ringtone to your Cell (.*)/m
				content = $1 # first of multiple lyrics -> remove ads
			end
			if content =~ /[...].*Unfortunately, we are not licensed to display the full lyrics for this song at the moment./m
				return "" # full lyrics 
			end
			return content
		end
		
		return ""
  end	
		
	def encodeUri(uri) 
    uri = uri.split.join("_")
    return URI.escape(uri, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end	
	
end