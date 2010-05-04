# FormulaParser.rb
# Lyrics-in-Sight-MacRuby
#
# Created by Michel Steuwer on 23.04.10.


class	FormulaParser
	
	def initWithDictionary(dictionary)
		if init
			@dictionary = dictionary
			self
		end
	end
	
	def evaluateNextAlternative(formula)
		location = formula.string =~ /\|/
		if location.nil? # last alternative: return empty string
			return NSAttributedString.new
		end
		# alternative found -> evaluate
		return evaluateFormula(formula.attributedSubstringFromRange([location + 1, formula.string.length - location - 1]))
	end
	
	def evaluateFormula(formula)
		output = NSMutableAttributedString.new
		while true
			
			if formula.string.length > 0 && formula.string[0] == "["
				location = formula.string =~ /\]/
				if location.nil?
					NSLog("Formula malformed: '[' without matching ']'")
					return NSAttributedString.new
				end
				# split
				condition = formula.attributedSubstringFromRange([1, location - 1])
				formula = formula.attributedSubstringFromRange([location + 1, formula.string.length - location - 1])
				# test condition
				if !evaluateCondition(condition)
					return evaluateNextAlternative(formula)
				end
			end
			
			location = formula.string =~ /[<\{\|]/
			# no special characters found -> append remaining formula and return output
			if location.nil?
				output.appendAttributedString(formula)
				return output
			end
			
			# split at speacial character (append string before, formula  = string after)
			output.appendAttributedString( formula.attributedSubstringFromRange([0, location]) )
			ch = formula.string[location]
			formula = formula.attributedSubstringFromRange([location + 1, formula.string.length - location - 1])
			
			case ch
			when "<"
				# search for matching closing character
				location = formula.string =~ />/
				if location.nil?
					NSLog("Formula malformed: '<' without matching '>'")
					return NSAttributedString.new
				end
				
				# split at closing character (token = string before, formula = string after)
				token = formula.attributedSubstringFromRange([0, location])
				formula = formula.attributedSubstringFromRange([location + 1, formula.string.length - location - 1])
				
				value = evaluateToken(token)
				if value.nil? # token evaluates to nil -> find next alternative
					return evaluateNextAlternative(formula)
				end
				# append evaluated token
				output.appendAttributedString(value)
			when "{"
				# search for (matching) closing character
				location = formula.string =~ /\}/
				if location.nil?
					NSLog("Formula malformed: '{' without matching '}'")
					return NSAttributedString.new
				end
				
				#split at first closing character
				part1 = NSMutableAttributedString.new
				part2 = NSMutableAttributedString.new
				part3 = formula.attributedSubstringFromRange([location + 1, formula.string.length - location - 1])
				temp  = NSMutableAttributedString.alloc.initWithString("{")
				temp.appendAttributedString(formula.attributedSubstringFromRange([0, location]))
				
				# search for matching opening character (may not be same as before)
				location = temp.string.rindex(/\{/)
				# NSAssert(location != nil, "'{' not found")
				#split
				part1 = temp.attributedSubstringFromRange([0, location])
				part2 = temp.attributedSubstringFromRange([location + 1, temp.string.length - location - 1])
				
				#append all first part, evaluated second part and thir part
				formula = NSMutableAttributedString.alloc.initWithAttributedString(part1)
				formula.appendAttributedString(evaluateFormula(part2))
				formula.appendAttributedString(part3)
			when "|"
				return output
			else
				NSLog("Invalid character found: #{formula.characterAtIndex(location)}");
			end
		end
	end
	
	def evaluateToken(token)
		if token.string =~ /<>\{\}\[\]\|/ # look for any special characters
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
		
		if condition.string !~ /==|!=/
			NSLog("Condition malformed: neither == nor != found")
			return false
		end
		
		# search for == operator
		location = condition.string =~ /==/
		equal = true
		
		if location.nil?
			# search for != operator
			location = condition.string =~ /!=/
			equal = false
		end
		
		# split condition at operator
		first = condition.attributedSubstringFromRange([0, location])
		second = condition.attributedSubstringFromRange([location + 2, condition.string.length - location - 2])
		
		# evaluate first operand
		if first.string.length > 0 && first.string[0] == '"' && first.string[first.length - 1] == '"'
			first = first.attributedSubstringFromRange([1, first.length - 2])
		elsif first.string.length > 0 && first.string[0] == '<' && first.string[first.length - 1] == '>'
			first = evaluateToken(first.attributedSubstringFromRange([1, first.length - 2]))
		else
			first = nil
		end
		
		# evaluate second operand
		if second.string.length > 0 && second.string[0] == '"' && second.string[second.length - 1] == '"'
			second = second.attributedSubstringFromRange([1, second.length - 2])
		elsif second.string.length > 0 && second.string[0] == '<' && second.string[second.length - 1] == '>'
			second = evaluateToken(second.attributedSubstringFromRange([1, second.length - 2]))
		else
			second = nil
		end
		
		# an operand was evaluated to nil -> return false
		#NSLog("First (#{first}) or second (#{second}) is nil")
		return false if first.nil? || second.nil?
		
		result = (first.string. == second.string)
		
		if equal
			return result
		else
			return !result
		end
	end
	
end
