# FormulaParser.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class	FormulaParser
	
	def initWithDictionary(dictionary)
		if init
			@dictionary = dictionary
			@specialCharacters = NSCharacterSet.characterSetWithCharactersInString("<>{}[]|")
			self
		end
	end
	
	def evaluateNextAlternative(formula)
		range = formula.rangeOfString("|")
		if range.location == NSNotFound # last alternative: return empty string
			return ""
		end
		# alternative found -> evaluate
		return evaluateFormula(formula.substringFromIndex(range.location + 1))
	end
	
	def evaluateFormula(formula)
		output = ""
		while true
			
			if formula.length > 0 && formula.characterAtIndex(0) == '['
				range = formula.rangeOfString("]")
				if range.location == NSNotFound
					NSLog("Formula malformed: '[' without matching ']'")
					return ""
				end
				# split
				condition = formula.substringWithRange(NSMakeRange(1, range.location - 1))
				formula = formula.substringFromIndex(range.location + 1)
				# test condition
				if !evaluateCondition(condition)
					return evaluateNextAlternative(formula)
				end
			end
			
			range = formula.rangeOfCharacterFromSet(NSCharacterSet.characterSetWithCharactersInString("<{|"))
			# no special characters found -> append remaining formula and return output
			if range.location == NSNotFound
				output << formula
				return output
			end
			
			# split at speacial character (append string before, formula  = string after)
			output << formula.substringToIndex(range.location)
			ch = formula.characterAtIndex(range.location)
			formula = formula.substringFromIndex(range.location + 1)
			
			case ch.chr
			when "<"
				# search for matching closing character
				range = formula.rangeOfString(">")
				if range.location == NSNotFound
					NSLog("Formula malformed: '<' without matching '>'")
					return ""
				end
				
				# split at closing character (token = string before, formula = string after)
				token = formula.substringToIndex(range.location)
				formula = formula.substringFromIndex(range.location + 1)
				
				value = evaluateToken(token)
				if value == nil # token evaluates to nil -> find next alternative
					return evaluateNextAlternative(formula)
				end
				# append evaluated token
				output << value
			when "{"
				# search for (matching) closing character
				range = formula.rangeOfString("}")
				if range.location == NSNotFound
					NSLog("Formula malformed: '{' without matching '}'")
					return ""
				end
				
				#split at first closing character
				part1 = ""
				part2 = ""
				part3 = formula.substringFromIndex(range.location + 1) 
				temp  = "{" << formula.substringToIndex(range.location)
				
				# search for matching opening character (may not be same as before)
				range = temp.rangeOfString("{", options: NSBackwardsSearch)
				# NSAssert(range.location != NSNotFound, "'{' not found")
				#split
				part1 = temp.substringToIndex(range.location)
				part2 = temp.substringFromIndex(range.location + 1)
				
				#append all first part, evaluated second part and thir part
				formula << part1 << evaluateFormula(part2) << part3
			when "|"
				return output
			else
				NSLog("Invalid character found: #{formula.characterAtIndex(range.location)}");
			end
		end
	end
	
	def evaluateToken(token)
		range = token.rangeOfCharacterFromSet(@specialCharacters)
		if range.location != NSNotFound
			NSLog("Malformed token #{token}")
			return nil
		end
		return @dictionary.objectForKey(token).description
	end
	
	def evaluateCondition(condition)
		# search for == operator
		range = condition.rangeOfString("==")
		equal = true
		
		if range.location == NSNotFound
			# search for != operator
			range = condition.rangeOfString("!=")
			equal = false
		end
		
		if range.location == NSNotFound
			NSLog("Condition malformed: neither == nor != found")
			return false
		end
		
		# split condition at operator
		first = condition.substringToIndex(range.location)
		second = condition.substringFromIndex(range.location + 2)
		
		# evaluate first operand
		if first.length > 0 && first.characterAtIndex(0) == '"' && first.characterAtIndex(first.length - 1) == '"'
			first = first.substringWithRange(NSMakeRange(1, first.length - 2))
		elsif first.length > 0 && first.characterAtIndex(0) == '<' && first.characterAtIndex(first.length - 1) == '>'
			first = evaluateToken(first.substringWithRange(NSMakeRange(1, first.length - 2)))
		else
			first = nil
		end
		
		# evaluate second operand
		if second.length > 0 && second.characterAtIndex(0) == '"' && second.characterAtIndex(second.length - 1) == '"'
			second = second.substringWithRange(NSMakeRange(1, second.length - 2))
		elsif second.length > 0 && second.characterAtIndex(0) == '<' && second.characterAtIndex(second.length - 1) == '>'
			second = evaluateToken(second.substringWithRange(NSMakeRange(1, second.length - 2)))
		else
			second = nil
		end
		
		# an operand was evaluated to nil -> return false
		if first == nil || second == nil
			return false
		end
		
		result = first.isEqualToString(second)
		
		if equal
			return result
		else
			return !result
		end
	end
	
end
