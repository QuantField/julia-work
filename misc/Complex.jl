type Cplex

# member variables
   x::Float64;
   y::Float64;

# methods   
   Real::Function;
   Imag::Function;

 function Cplex(x::Float64,y::Float64;)  
   
   this = new();
   
   this.x = x;
   
   this.y = y;
 
   this.Real = function()
     return x;
   end
   
   this.Imag = function()
     return y;
   end
    
   return this
 
 end 

end   