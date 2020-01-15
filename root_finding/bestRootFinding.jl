function bisect(f::Function, a::Float64, b::Float64, iter :: Int)
    fa,fb = f(a),f(b)
	for i=1:iter 	
	    mid  = (a+b)/2.
		fmid = f(mid)         
		if (fa*fmid)<0
			b, fb = mid, fmid
		else 
			a, fa = mid, fmid		
		end		
	end
    return a,fa,b,fb	
end	


function frootSec(f::Function, a::Float64, b::Float64)
   epsilon, MaxIter = 1.0E-6, 50 
   fa,  fb   = f(a),f(b)
   x2 = (a+b)/2.
   iter = 0
   if fa*fb>0
     println("No solution")
   else         
		while true 	
		    if ((iter%3==0 && (x2<a || x2>b)) || iter==0)
			  a,fa,b,fb = bisect(f,a,b,3) 
              x1, f1, x2, f2  = a, fa, b, fb
			end             			
		    iter+=1
            xv, fv = x2, f2		
		    x2 = x2 - (x2-x1)*f2/(f2-f1)
			f2 = f(x2)
			x1, f1 = xv, fv	
			#@printf("x = %4.8f    f(x) = %4.8f\n", x2, f2)
			if abs((x1-x2)/x1)<epsilon
			   break
			end	
		end	
        return iter, x2		
   end
end   






