type Algo
   ls :: lssvm
   r  :: Float64
   
   function Algo(p::lssvm, x::Float64)
      this = new();
      this.ls = p;
	  this.r = x;
	 
	  return this;
   end
end 