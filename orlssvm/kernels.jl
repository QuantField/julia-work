abstract type Kernel end

#------------------------ Linear-------------------------------------           
mutable struct linear <: Kernel
	
	name :: String 
	evaluate :: Function

	function linear()
		
		self = new()
		
		self.name = "Linear"
        
        self.evaluate = 
        function (x1:: Array{Float64,2}, x2:: Array{Float64,2})  
        	K= x2*x1'   
        end 

        self
    end
end


#------------------------ Polynomia ------------------------------------        
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
        function (x1:: Array{Float64,2}, x2:: Array{Float64,2})  
        	K =  (x2*x1' .+ self.offset).^self.order    
        end 

		self
	end
end

#------------------------ RBF-------------------------------------     
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
             K = sum(x1.^2, dims=2) * ones(1,size(x2,1)) +
                 ones(size(x1,1),1) * sum(x2.^2,dims=2)' - 2*x1*x2';        
             K = exp.(-K/(self.width^2))
        end 

		self
	end
end

#------------------------ Demo ------------------------------
ker1 = linear()
ker2 = polynomial(2., 0.1)
ker3 = rbf()

a = rand(6000,3)
b = rand(6000,3)  

for r in [ker1, ker2, ker3]
	println(r.name)
	@time r.evaluate(a,b)
end

