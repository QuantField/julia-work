function frootGol(f::Function, a0::Float64, b0::Float64)
   # a<b
   r = (-1.+sqrt(5.))/2.
   epsilon, MaxIter = 1.0E-6, 50
   x1 = x2 = 0.
   a, b  = a0, b0
   cache = 9999999999.;
   fa,  fb   = f(a),f(b)
   if fa*fb>0
     println("No solution")
   else      
		while true 
			x1, x2  = r*a+(1-r)*b, (1-r)*a + r*b
			f1, f2  = f(x1),f(x2)
			if  fa*f1<0
				 b, fb = x1, f1
			  elseif f1*f2<0  			   
				a, fa = x1, f1
				b, fb = x2, f2
			  else 
               a, fa = x2, f2			  
			end		
			#@printf("x1 = %4.8f  x2 = %4.8f  f(x1) = %4.8f  f(x2) = %4.8f\n",x1, x2, f1, f2)
			if abs((x1-cache)/cache)<epsilon
			   break
			end	
            cache = x1			
		end	
        return (x1+x2)/2.		
   end
end   

function froot(f::Function, a::Float64, b::Float64)
   epsilon, MaxIter = 1.0E-6, 50
   low, high = a, b
   cache = 9999999999.
   mid = 0.
   fl,  fh   = f(low),f(high)
   if fl*fh>0
     println("No solution")
   else      
		while true 
			mid  = (low+high)/2.
			fmid = f(mid) 
			if (fl*fmid)<0
				high, fh = mid, fmid
			else 
				low, fl = mid, fmid		
			end		
			#@printf("x = %4.8f    f(x) = %4.8f\n", mid, fmid)
			if abs((mid-cache)/cache)<epsilon
			   break
			end	
            cache = mid				
		end		
		return mid
   end
end   

function frootGol2(f::Function, a::Float64, b::Float64)
   r = (-1.+sqrt(5.))/2.
   epsilon, MaxIter = 1.0E-8, 50
   mid = 0.
   low, high = a, b
   cache = 9999999999.;
   fl,  fh   = f(low),f(high)
   if fl*fh>0
     println("No solution")
   else      
		while true 
			mid  = r*low+(1-r)*high
			fmid = f(mid) 
			if (fl*fmid)<0
				high, fh = mid, fmid
			else 
				low, fl = mid, fmid		
			end		
			#@printf("x = %4.8f    f(x) = %4.8f\n", mid, fmid)
			if abs((mid-cache)/cache)<epsilon
			   break
			end	
            cache = mid			
		end	
        return mid		
   end
end   




function frootSec(f::Function, a::Float64, b::Float64)
   epsilon, MaxIter = 1.0E-6, 50 
   fa,  fb   = f(a),f(b)
   x2 = 0.
   if fa*fb>0
     println("No solution")
   else    
        x1, f1 = a, fa
        x2 = (a+b)/2. 
        f2 = f(x2)		
		while true 	
            xv, fv = x2, f2		
		    x2 = x2 - (x2-x1)*f2/(f2-f1)
			f2 = f(x2)
			x1, f1 = xv, fv	
			#@printf("x = %4.8f    f(x) = %4.8f\n", x2, f2)
			if abs((x1-x2))<epsilon
			   break
			end	            
		end	
        return x2		
   end
end   
















