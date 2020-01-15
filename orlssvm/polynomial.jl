abstract type Kernel end



mutable struct polynomial <: Kernel
	
	name::String 
	order::Float64
	offset::Float64

	evaluate::Function

	function polynomial(order::Float64, offset::Float64=1.)
		
		self = new()			
		self.name = "Polynomial"
		self.order = order
		self.offset = offset
        
        self.evaluate = 
        function (x1:: Array{Float64,}, x2:: Array{Float64,})  
        	evaluate(self, x1:: Array{Float64,2}, x2:: Array{Float64,2})    
        end 

		self
	end

end

function evaluate(ker::polynomial, x1:: Array{Float64,2}, x2:: Array{Float64,2}) 
	 return   (x2*x1' .+ ker.offset).^ker.order
end


ker = polynomial(2., 0.5)
println(ker.name)

a = rand(600,3)
b = rand(600,3)  
c = ker.evaluate(a,b)
print(size(c))

