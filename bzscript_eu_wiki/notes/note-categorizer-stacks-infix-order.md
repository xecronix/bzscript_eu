ah... and there it is.  The thing I keep getting tripped up on.  Now I see it clearly.  
categorizer needs to know the difference between 

this:
fun f(#a,#b,#c) // where a, b, c are just tokens in sequential order.
end 
fun begin
	#z = 5
	#y = 10
	#x = #y + #z
	f(#x,#y,#z)
end 

and this:
	#x = #y + #z

where call  
on in the last expression of f in need to evaluate tokens in a different order than in the previuos expression.

f is going to call an ant.  Called 'call' in this case. with the params in a particular order.
+ is going to call an ant.  Called 'sum' in this case.  with the params visualy represented in a different order that was used for f.

The categrorizer is going to have to understand the order of the code.  
f - 3 params left to right order
+ - 2 params one on the left and one on the right.
