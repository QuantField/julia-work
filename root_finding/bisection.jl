f(x) = (x+1.0000)*(x+0.2500)*(x+0.1111)*(x+0.0625)

# serach grid but more granular twards the end 
# this type of grid is suitable for solving shrodinger equation with central potential
Emin = -2.;
lnEmin = log(abs(Emin));
lnZero = -6.; 
N = 100;
gridLog = collect(linspace(lnZero,lnEmin,N));
grid  = -exp(gridLog)
searchGrid = grid[end:-1:1]


function findInterval(f::Function, grid::Array{Float64,1})
    maxSol = 10;
	index = round(Int,zeros(maxSol,1));
	j = 1;
	for i=1:length(grid)-1
	  if f(grid[i])*f(grid[i+1])<0.
	      println("solution found")
          index[j]=i
		  j+=1
	  end
	end
	return index[index.!=0]
end
	
	  



function froot(f::Function, a::Float64, b::Float64)
   epsilon, MaxIter = 1.0E-6, 50
   low, high = a, b
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
			@printf("x = %4.8f    f(x) = %4.8f\n", mid, fmid)
			if abs(fmid)<epsilon
			   break
			end			
		end		
   end
end   

function frootGol(f::Function, a::Float64, b::Float64)
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

indSol = findInterval(f, searchGrid)

for i=1:length(indSol)
   pos = indSol[i];
   println("x =",froot(f,searchGrid[pos],searchGrid[pos+1]))
end   














		
	    
        