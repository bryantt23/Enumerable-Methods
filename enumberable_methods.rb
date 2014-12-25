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



    def my_count
        return self.to_enum unless block_given?
        counter = 0
        for i in self
            counter +=1 if yield i
        end
        return counter
    end

    def my_map(proc=nil)
        resp = []
        if block_given? && proc
            for i in self
                resp.push(proc.call(yield i))
            end
            return resp
        elsif proc
            for i in self
                resp.push(proc.call i)
            end
            return resp
        else
            return self.to_enum unless block_given?
            for i in self
                resp.push(yield i)
            end
            return resp
        end
    end

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
=end
@a = ["a","bit city life","c","hold on tight","e","zzzz","hit me up"]
@b = {a: "bit city life",c: "hold on tight",p: "piratess"}

puts @a.my_any? {|a| a[0] == 'j'}
puts @a.any? {|a| a[0] == 'j'}


puts @b.my_any? {|a,b| b[0] == 'h'}
puts @b.any? {|a,b| b[0] == 'h'}

=begin
@a.my_none? {|a| a[0] == 'h'}
@a.none? {|a| a[0] == 'h'}
@b.my_none? {|a,b| a[0] == 'h'}
@b.none? {|a,b| a[0] == 'h'}

@a.my_count {|a| a[0] == 'h'}
@a.count {|a| a[0] == 'h'}
@b.my_count {|a,b| a[0] == 'h'}
@b.count {|a,b| a[0] == 'h'}

@a.my_map {|a| a[0] == 'h'}
@a.map {|a| a[0] == 'h'}
@b.my_map {|a,b| b[0] == 'h'}
@b.map {|a,b| b[0] == 'h'}

=end

def multiply_els ary
    return ary.my_inject { |product, n| product * n }
end

multiply_els([2,4,5])