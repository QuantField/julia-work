abstract type Kernel end



mutable struct linear <: Kernel
	
	name :: String 
	evaluate :: Function

	function linear()
		
		self = new()
		
		self.name = "Linear"
        
        self.evaluate = 
        function (x1:: Array{Float64,}, x2:: Array{Float64,})  
        	evaluate(self, x1:: Array{Float64,2}, x2:: Array{Float64,2})    
        end 

		self
	end

end

function evaluate(ker::linear, x1:: Array{Float64,}, x2:: Array{Float64,}) 
	 return x2*x1'
end

# ker = linear()
# println(ker.name)

# a = rand(600,3)
# b = rand(600,3)  
# c = ker.evaluate(a,b)
# print(size(c))

