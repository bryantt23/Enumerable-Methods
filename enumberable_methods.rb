module Enumerable
  
  # http://stackoverflow.com/questions/2863044/what-is-the-advantage-of-creating-an-enumerable-object-using-to-enum-in-ruby
  #i think the .to_enum is to use the internal/self made enum/iterators, but i'm not sure
  #i think the each just iterates each thing
    def my_each
        return self.to_enum unless block_given?
#        http://www.jimmycuadra.com/posts/self-in-ruby
        for i in self
            yield i
        end
    end

=begin

The keyword self in Ruby gives you access to the current object – the object that is receiving the current message. 
To explain: a method call in Ruby is actually the sending of a message to a receiver. 
When you write obj.meth, you're sending the meth message to the object obj. 
obj will respond to meth if there is a method body defined for it. And inside that method body, self refers to obj. 
When I started with Ruby, I learned this pretty quickly, but it wasn't totally apparent when you might actually need to use self.


Yield is Syntax Sugar
This example of yield:

def do_something_for_each(array)
  array.each do |el|
    yield(el)
  end
end
Is just syntax sugar for:

def do_something_for_each(array, &block)
  array.each do |el|
    block.call(el)
  end
end
Pick the syntax you like and run wild with it.  
=end

    def my_each_with_index
        return self.to_enum unless block_given?
#        Kernel#block_given? is a method which returns true if yield actually has something to do. Neat, huh?
# i guess this is the index
        idx = 0
        
        #http://stackoverflow.com/questions/14309815/why-does-ruby-use-yield
        for i in self
          #show item and index i think
            yield i, idx
#increment index
            idx += 1
        end
    end


    def my_select
        return self.to_enum unless block_given?
        #looks like it makes a copy
        copy = self.dup        
        
=begin 
        dup → an_object click to toggle source
Produces a shallow copy of obj—the instance variables of obj are copied, but not the objects they reference. dup copies the tainted state of obj.
=end

               for i in self
#checks to see if it is the same class as the Array

#i don't understand this part
            if copy.class == Array
                copy.delete(i) unless yield i
            else
                copy.delete(i[0]) unless yield i
            end
        end
        return copy
    end

=begin
puts %w[ant bear cat].my_all? { |word| word.length >= 3 } 

ok maybe block_given refers to the word length >=3
not sure, but maybe if it is >=3 it runs this my_all method

%w[ant bear cat].all? { |word| word.length >= 4 } #=> false

but i think--idk, i'll come back to this one day...
must move on
=end

#or all true for all to be true
#i guess it needs 1 false for all to be false
    def my_all?
        return self.to_enum unless block_given?
        for i in self
            return false unless yield i
        end
        return true
    end

#looks like it is just the opposite of my all
#it just needs 1 and only 1 to be true for my any to be true
    def my_any?
        return self.to_enum unless block_given?
        for i in self
            return true if yield i
        end
        return false
    end

#needs all false for my none to be true
#just 1 true means my none is false
    def my_none?
        return self.to_enum unless block_given?
        for i in self
            return false if yield i
        end
        return true
    end
=begin
ok i guess the pattern is yield means true
for all, it is false unless each item yields. but if there is 1 item that doesn't yield, all = false
for any, it is true if there is just 1 item that yields
for none, it is false if there is just 1 item that yields  
=end


#increment every time it yields or is true?
    def my_count
        return self.to_enum unless block_given?
        counter = 0
        for i in self
            counter +=1 if yield i
        end
        return counter
    end
    
=begin
  map { |obj| block } → array 
map → an_enumerator
Returns a new array with the results of running block once for every element in enum.

the map just takes an array and makes a new one
i'll just think of map as make a pnew array

print (1..4).my_map { |i| i*i }      #=> [1, 4, 9, 16]
#proc means procedure, i guess that's the parameter
=end

    def my_map(proc=nil)
#empty array
        resp = []
        #if there is a block & a procedure?
        if block_given? && proc
            for i in self
                #push onto the array the procedure call for each element
                resp.push(proc.call(yield i))
            end
            return resp
            #if there is only a procedure given?
        elsif proc
            for i in self
                resp.push(proc.call i)
            end
            return resp
        else #not sure what this means
            return self.to_enum unless block_given?
            for i in self
                resp.push(yield i)
            end
            return resp
        end
    end

=begin http://ruby.bastardsbook.com/chapters/enumerables/
The inject method takes a collection and reduces it to a single value, such as a sum of values:
val = [1,3,5,7].inject(0) do |total, num|
   total += num
end   
puts val   #=> 16

=end

=begin
	inject {| memo, obj | block } → obj
Combines all elements of enum by applying a binary operation, specified by a block or a symbol that names a method or operator.

If you specify a block, then for each element in enum the block is passed an accumulator value (memo) and the element. If you specify a symbol instead, then each element in the collection will be passed to the named method of memo. In either case, the result becomes the new value for memo. At the end of the iteration, the final value of memo is the return value for the method.

If you do not explicitly specify an initial value for memo, then uses the first element of collection is used as the initial value of memo.
=end

#i think in1 is operator, in2 is value
    def my_inject in1=nil, in2=nil
        return self.to_enum unless block_given? || in1 || in2
        
        if in1 == nil #no input
            initial = false
            for i in self
                if initial
                    initial = yield initial, i
                else
                    initial = i
                end
            end
        elsif in2 == nil #only 1 input
            if in1.class == Symbol # break out if symbol/not symbol
                # add case statements for treating operations, like +, -, /, *, etc
            else
                initial = in1
                for i in self
                    initial = yield initial, i
                end
            end
            
        else #two inputs
            initial = in1
            # add case statements for treating operations, like +, -, /, *, etc
            for i in self
                initial = yield initial, i
            end
        end
        return initial
    end
end




=begin


@a = ["a","bit city life","c","hold on tight","e","zzzz","hit me up"]
@b = {a: "bit city life",c: "hold on tight",p: "piratess"}

  #looks like it is just comparing self made methods to enumerable methods
@a.my_each {|a| puts "#{a}"}
@a.each {|a| puts "#{a}"}

  http://www.ruby-doc.org/core-2.1.5/Hash.html#method-i-each
  h = { "a" => 100, "b" => 200 }
h.each {|key, value| puts "#{key} is #{value}" }
produces:

a is 100
b is 200


@b.my_each {|a,b| puts "#{a} #{b}"}
@b.each {|a,b| puts "#{a} #{b}"}


@a.my_each_with_index {|a,b| puts "#{a} #{b}"}
@a.each_with_index {|a,b| puts "#{a} #{b}"}
#@a.each_with_index {|a,b| puts "#{b}. #{a}"}




=begin
  hash = Hash.new
%w(cat dog wombat).each_with_index {|item, index|
  hash[item] = index
}
hash   #=> {"cat"=>0, "dog"=>1, "wombat"=>2}

@b.my_each_with_index {|a,b| puts "#{a} #{b}"}
@b.each_with_index {|a,b| puts "#{a} #{b}"}



@a.my_select {|a| a[0] == 'h'}
@a.select {|a| a[0] == 'h'}

#select
#This useful method takes in one argument. The block you pass it should be some kind of true/false test. 
#If the expression results in true for an element in an array, that element is kept as part of the returned collection
#i think it only keeps the desired items 
puts [1,'a', 2, 'dog', 'cat', 5, 6].select{ |x| x.class==String}.join(", ")           
puts [1,'a', 2, 'dog', 'cat', 5, 6].my_select{ |x| x.class==String}.join(", ")           



@b.my_select {|a,b| b[0] == 'h'}
@b.select {|a,b| b[0] == 'h'}

@a = ["a","bit city life","c","hold on tight","e","zzzz","hit me up"]
@b = {a: "bit city life",c: "hold on tight",p: "piratess"}


=end

=begin
all? [{ |obj| block } ] → true or false 
Passes each element of the collection to the given block. The method returns true if the block never returns false or nil.   

%w[ant bear cat].all? { |word| word.length >= 3 } #=> true
%w[ant bear cat].all? { |word| word.length >= 4 } #=> false
[nil, true, 99].all?                              #=> false

@a.my_all? {|a| a[0] == 'h'}
@a.all? {|a| a[0] == 'h'}


puts %w[ant bear cat].all? { |word| word.length >= 3 } 
puts %w[ant bear cat].my_all? { |word| word.length >= 3 } 
puts %w[ant bear cat].my_all? { |word| word.length >= 4 } #=> false


@b.my_all? {|a,b| a[0] == 'h'}
@b.all? {|a,b| a[0] == 'h'}



any? [{ |obj| block }] → true or false click to toggle source
Passes each element of the collection to the given block. The method returns true if the block ever returns a value other than false or nil.

puts @a.my_any? {|a| a[0] == 'j'}
puts @a.any? {|a| a[0] == 'j'}


puts @b.my_any? {|a,b| b[0] == 'h'}
puts @b.any? {|a,b| b[0] == 'h'}


@a.my_none? {|a| a[0] == 'h'}
@a.none? {|a| a[0] == 'h'}
@b.my_none? {|a,b| a[0] == 'h'}
@b.none? {|a,b| a[0] == 'h'}

puts @a.my_count {|a| a[0] == 'h'}
puts @a.count {|a| a[0] == 'h'}
puts @b.my_count {|a,b| a[0] == 'h'}
puts @b.count {|a,b| a[0] == 'h'}
@a = ["a","bit city life","c","hold on tight","e","zzzz","hit me up"]
@b = {a: "bit city life",c: "hold on tight",p: "piratess"}

@a.my_map {|a| a[0] == 'h'}
@a.map {|a| a[0] == 'h'}
@b.my_map {|a,b| b[0] == 'h'}
@b.map {|a,b| b[0] == 'h'}

print (1..4).map { |i| i*i }      #=> [1, 4, 9, 16]
print (1..4).my_map { |i| i*i }      #=> [1, 4, 9, 16]

=end

def multiply_els ary
    return ary.my_inject { |product, n| 
      product * n }
end

puts multiply_els([2,4,5])

def add_els ary
    return ary.my_inject { |sum, n| 
      sum += n }
end
puts add_els([2,4,5])

val = [1,3,5,7].inject(0) do |total, num|
   total += num
end   
puts val   #=> 16

puts (5..10).inject {|sum, n| sum + n }            #=> 45


arr = 18.times.inject([0,1]) do |a, idx|
    a << a[-2] + a[-1]
end       

puts arr.join(', ')
#=> 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181


=begin
	Create an array of the Fibonacci sequence with inject

The Fibonacci sequence consists of a sequence of integers in which each number is the sum of the previous two numbers in the sequence. By definition, the first two numbers are 0 and 1.

0,1,1,2,3,5,8,13...

The Fibonacci sequence is one of the most famous in mathematics as its properties have been observed in numerous fields, including the Golden Ratio used in the arts and the natural arrangement of a plant's leaves.

Here's one way of creating an array with the first 20 Fibonacci numbers using a loop:


arr = [0,1]
18.times do
    arr << arr[-2] + arr[-1]
end        
    
Remember that negative indexes count backwards from the end of the array. So arr[-2] – when arr = [0,1] – points to the value of 0. At the end of each iteration, arr increases in length by 1.
=end