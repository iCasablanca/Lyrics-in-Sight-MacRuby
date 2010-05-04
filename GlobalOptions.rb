# GlobalOptions.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 27.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

require 'singleton'

class GlobalOptions
	include Singleton
	
	def	setOption(key, value)
		@options = Hash.new if @options.nil?
		@options[key] = value
	end
	
	def	getOption(key)
		return @options[key]
	end
	
end
