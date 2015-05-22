#!# From Tom Dalling's post titled "FizzBuzz in Too Much Detail"
#!# http://www.tomdalling.com/blog/software-design/fizzbuzz-in-too-much-detail/?utm_source=rubyweekly&utm_medium=email


# A Naive Implementation
1.upto(100) do |i|
  if i % 3 == 0 && i % 5 == 0
    puts 'FizzBuzz'
  elsif i % 3 == 0
    puts 'Fizz'
  elsif i % 5 == 0
    puts 'Buzz'
  else
    puts i 
  end      
end
puts " "


# Don't Repeat Yourself
1.upto(100) do |i|
  fizz = (i % 3 == 0)
  buzz = (i % 5 == 0)
  puts case 
       when fizz && buzz then 'FizzBuzz'
       when fizz then 'Fizz'
       when buzz then 'Buzz'
       else i
       end
end
puts " "


# More Deduplication
FIZZ = 'Fizz'
BUZZ = 'Buzz'
def divisible_by?(numerator, denominator)
  numerator % denominator == 0
end
1.upto(100) do |i|
  fizz = divisible_by?(i, 3)
  buzz = divisible_by?(i, 5)
  puts case 
       when fizz && buzz then FIZZ + BUZZ 
       when fizz then FIZZ
       when buzz then BUZZ
       else i
       end
end
puts " "


# Parameterization -- the range of integers covered; the text that is output; the multiples that trigger text to be output.
def fizzbuzz(range, triggers)
  range.each do |i|
    result = ''
    triggers.each do |(text, divisor)|
      result << text if i % divisor == 0
    end
    puts result == '' ? i : result
  end
end
fizzbuzz(1..100, [
  ['Fizz', 3],
  ['Buzz', 5],
])
puts " "


# More Parameterization -- "Zazz" on all numbers less than 10.
def fizzbuzz(range, triggers)
  range.each do |i|
    result = ''
    triggers.each do |(text, predicate)|
      result << text if predicate.call(i)
    end
    puts result == '' ? i : result
  end
end
fizzbuzz(1..100, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])
puts " "


# Fuctional Programming -- here is an implementation that returns the output instead of printing it 
def fizzbuzz(range, triggers)
  range.map do |i|  # changing range.each to range.map converts the range into an array of outputs that is then returned
                    # instead of printing each value with puts, we just puts the whole array returned from the fizzbuzz function
    result = ''
    triggers.each do |(text, predicate)|
      result << text if predicate.call(i)
    end
    result == '' ? i : result
  end
end
puts fizzbuzz(1..100, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])
puts " "


# Taking the Functional style even further ...
def fizzbuzz(range, triggers)
  range.map do |i|
    parts = triggers.select{ |(_, predicate)| predicate.call(i) }
    parts.size > 0 ? parts.map(&:first).join : i
  end
end
puts fizzbuzz(1..100, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])
puts " "


# Lazy Generation -- what if we needed to generate terabytes of output? 
# In this implementation, we generate a single output value, print it, throw it away, then repeat.
# Although there is still some functional-style code at the core, this implementation isn't very functional.
# Enumerators are stateful, and every call to next is mutating the enumerator
def fizzbuzz(start, triggers)
  Enumerator.new do |yielder|
    i = start
    loop do
      parts = triggers.select{ |(_, predicate)| predicate.call(i) }
      i_result = parts.size > 0 ? parts.map(&:first).join : i 
      yielder.yield(i_result)
      i += 1 
    end
  end
end
enumerator = fizzbuzz(1, [
  ['Fizz', ->(i){ i % 3 == 0 }],
  ['Buzz', ->(i){ i % 5 == 0 }],
  ['Zazz', ->(i){ i < 10 }],
])
#!# The following loop command will tell the computer to run this program until the i variable is a single number so large 
#!# that it won't fit into memory. Use it at your own peril, and have ctrl-c ready.
#!# loop { puts enumerator.next }
puts " "


####################################################################
# Polishing For Distribution -- The Ultimate FizzBuzz Implementation
module FizzBuzz
  DEFAULT_RANGE = 1..100
  DEFAULT_TRIGGERS = [
    ['Fizz', ->(i){ i % 3 == 0 }],
    ['Buzz', ->(i){ i % 5 == 0 }],
  ]

  ##
  # Makes an array of FizzBuzz values for the given range and triggers.
  #
  # @param range [Range<Integer>] FizzBuzz integer range 
  # @param triggers [Array<Array(String, Integer)>] An array of [text, predicate]
  # @return [Array,String>] FizzBuzz results
  #
  def self.range(range=DEFAULT_RANGE, triggers=DEFAULT_TRIGGERS)
    enumerator(range.first, triggers).take(range.size)
  end

  ##
  # Makes a FizzBuzz value enumerator, starting at the given integer, for the given triggers.
  #
  # @param start [Integer] The first integer to FizzBuzz
  # @param triggers [Array<Array(String, Integer)>] An array of [text, predicate]
  # @return [Enumerable] Infinite sequence of FizzBuzz results
  #
  def self.enumerator(start=DEFAULT_RANGE.first, triggers=DEFAULT_TRIGGERS)
    Enumerator.new do |yielder|
      i = start 
      loop do
        parts = triggers.select{ |(_, predicate)| predicate.call(i) }
        i_result = parts.size > 0 ? parts.map(&:first).join : i.to_s
        yielder.yield(i_result)
        i += 1
      end
    end
  end

end

# Example usage code:
p FizzBuzz.range(1..5)
p FizzBuzz.range(1..5, [['Odd', ->(i){ i.odd? }]])
e = FizzBuzz.enumerator
p e.next
p e.next
p e.next
p e.next
p e.next
p e.next
puts " "


#!# Final Notes #!#
# Notice how the code became more complex as we progressed. Is that what we really want? After all, it's Freakin' FizzBuzz!
# This was a fun and informative exercise, but I think the most important lesson was YAGNI: You Ain't Gonna Need It.
