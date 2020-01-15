abstract type Kernel end


mutable struct rbf <: Kernel	
	name::String 
	width::Float64
	
	evaluate::Function

	function rbf(width::Float64=1.)
		
		self = new()			
		self.name = "RBF"
		self.width = width		
        
        self.evaluate = 
        function (x1:: Array{Float64,2}, x2:: Array{Float64,2})  
        	evaluate(self, x1:: Array{Float64,2}, x2:: Array{Float64,2})    
        end 

		self
	end
end

function evaluate(ker::rbf, x1:: Array{Float64,2}, x2:: Array{Float64,2}) 
	 K = sum(x1.^2,dims=2)*ones(1,size(x2,1))+ones(size(x1,1),1)*sum(x2.^2,dims=2)'-2*x1*x2';		 
     K = exp.(-K/(ker.width^2))
     return K	     

end





ker = rbf()
println(ker.name)

a = rand(6000,3)
b = rand(6000,3)  
c = ker.evaluate(a,b)
print(size(c))

