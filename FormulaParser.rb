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
		range = formula.string.rangeOfString("|")
		if range.location == NSNotFound # last alternative: return empty string
			return NSAttributedString.new
		end
		# alternative found -> evaluate
		return evaluateFormula(formula.attributedSubstringFromRange([range.location + 1, formula.string.length - range.location - 1]))
	end
	
	def evaluateFormula(formula)
		output = NSMutableAttributedString.new
		while true
			
			if formula.string.length > 0 && formula.string.characterAtIndex(0).chr == "["
				range = formula.string.rangeOfString("]")
				if range.location == NSNotFound
					NSLog("Formula malformed: '[' without matching ']'")
					return NSAttributedString.new
				end
				# split
				condition = formula.attributedSubstringFromRange([1, range.location - 1])
				formula = formula.attributedSubstringFromRange([range.location + 1, formula.string.length - range.location - 1])
				# test condition
				if !evaluateCondition(condition)
					return evaluateNextAlternative(formula)
				end
			end
			
			range = formula.string.rangeOfCharacterFromSet(NSCharacterSet.characterSetWithCharactersInString("<{|"))
			# no special characters found -> append remaining formula and return output
			if range.location == NSNotFound
				output.appendAttributedString(formula)
				return output
			end
			
			# split at speacial character (append string before, formula  = string after)
			output.appendAttributedString( formula.attributedSubstringFromRange([0, range.location]) )
			ch = formula.string.characterAtIndex(range.location)
			formula = formula.attributedSubstringFromRange([range.location + 1, formula.string.length - range.location - 1])
			
			case ch.chr
			when "<"
				# search for matching closing character
				range = formula.string.rangeOfString(">")
				if range.location == NSNotFound
					NSLog("Formula malformed: '<' without matching '>'")
					return NSAttributedString.new
				end
				
				# split at closing character (token = string before, formula = string after)
				token = formula.attributedSubstringFromRange([0, range.location])
				formula = formula.attributedSubstringFromRange([range.location + 1, formula.string.length - range.location - 1])
				
				value = evaluateToken(token)
				if value == nil # token evaluates to nil -> find next alternative
					return evaluateNextAlternative(formula)
				end
				# append evaluated token
				output.appendAttributedString(value)
			when "{"
				# search for (matching) closing character
				range = formula.string.rangeOfString("}")
				if range.location == NSNotFound
					NSLog("Formula malformed: '{' without matching '}'")
					return NSAttributedString.new
				end
				
				#split at first closing character
				part1 = NSMutableAttributedString.new
				part2 = NSMutableAttributedString.new
				part3 = formula.attributedSubstringFromRange([range.location + 1, formula.string.length - range.location - 1])
				temp  = NSMutableAttributedString.alloc.initWithString("{")
				temp.appendAttributedString(formula.attributedSubstringFromRange([0, range.location]))
				
				# search for matching opening character (may not be same as before)
				range = temp.string.rangeOfString("{", options: NSBackwardsSearch)
				# NSAssert(range.location != NSNotFound, "'{' not found")
				#split
				part1 = temp.attributedSubstringFromRange([0, range.location])
				part2 = temp.attributedSubstringFromRange([range.location + 1, temp.string.length - range.location - 1])
				
				#append all first part, evaluated second part and thir part
				formula = NSMutableAttributedString.alloc.initWithAttributedString(part1)
				formula.appendAttributedString(evaluateFormula(part2))
				formula.appendAttributedString(part3)
			when "|"
				return output
			else
				NSLog("Invalid character found: #{formula.characterAtIndex(range.location)}");
			end
		end
	end
	
	def evaluateToken(token)
		range = token.string.rangeOfCharacterFromSet(@specialCharacters)
		if range.location != NSNotFound
			NSLog("Malformed token #{token}")
			return nil
		end
		resultString = @dictionary[token.string].description
		attributes = token.attributesAtIndex(0, effectiveRange: nil)
		if !resultString || resultString == ""
			return nil
		else
			return NSAttributedString.alloc.initWithString(resultString, attributes: attributes)
		end
	end
	
	def evaluateCondition(condition)
		# search for == operator
		range = condition.string.rangeOfString("==")
		equal = true
		
		if range.location == NSNotFound
			# search for != operator
			range = condition.string.rangeOfString("!=")
			equal = false
		end
		
		if range.location == NSNotFound
			NSLog("Condition malformed: neither == nor != found")
			return false
		end
		
		# split condition at operator
		first = condition.attributedSubstringFromRange([0, range.location])
		second = condition.attributedSubstringFromRange([range.location + 2, condition.string.length - range.location - 2])
		
		# evaluate first operand
		if first.string.length > 0 && first.string.characterAtIndex(0).chr == '"' && first.string.characterAtIndex(first.length - 1).chr == '"'
			first = first.attributedSubstringFromRange([1, first.length - 2])
		elsif first.string.length > 0 && first.string.characterAtIndex(0).chr == '<' && first.string.characterAtIndex(first.length - 1).chr == '>'
			first = evaluateToken(first.attributedSubstringFromRange([1, first.length - 2]))
		else
			first = nil
		end
		
		# evaluate second operand
		if second.string.length > 0 && second.string.characterAtIndex(0).chr == '"' && second.string.characterAtIndex(second.length - 1).chr == '"'
			second = second.attributedSubstringFromRange([1, second.length - 2])
		elsif second.string.length > 0 && second.string.characterAtIndex(0).chr == '<' && second.string.characterAtIndex(second.length - 1).chr == '>'
			second = evaluateToken(second.attributedSubstringFromRange([1, second.length - 2]))
		else
			second = nil
		end
		
		# an operand was evaluated to nil -> return false
		if first == nil || second == nil
			NSLog("First (#{first}) or second (#{second}) is nil")
			return false
		end
		
		result = (first.string. == second.string)
		
		if equal
			return result
		else
			return !result
		end
	end
	
end
