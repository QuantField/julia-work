using Statistics
using LinearAlgebra

abstract type Kernel end


#------------------------ Linear-------------------------------------           
mutable struct linear <: Kernel		
    name :: String 
	linear() = new("Linear")	
end

function evaluate(net::linear, x1:: Array{Float64,2}, x2:: Array{Float64,2})  
    K= x2*x1'   
end 
 

#------------------------ Polynomia ------------------------------------        
mutable struct polynomial <: Kernel	
	name::String 
	order::Float64
	offset::Float64
	polynomial(order::Float64=2., offset::Float64=1.) = new("Polynomial",order, offset)
end

function evaluate(net::polynomial, x1:: Array{Float64,2}, x2:: Array{Float64,2})  
    K =  (x2*x1' .+ net.offset).^net.order    
end 



#------------------------ RBF-------------------------------------     
mutable struct rbf <: Kernel	
	name::String 
	width::Float64
	rbf(width::Float64=1.)	= new("RBF", width)
end

function evaluate(net::rbf, x1:: Array{Float64,2}, x2:: Array{Float64,2})  
     K = sum(x1.^2, dims=2) * ones(1,size(x2,1)) +
         ones(size(x1,1),1) * sum(x2.^2,dims=2)' - 2*x1*x2';        
     K = exp.(-K/(net.width^2))
end 

function set_std_width(net::rbf, x::Array{Float64,2})
    net.width = norm(std(x,dims=1))
end

 



a = rand(3,2)
b = rand(3,2)

v = evaluate(linear(),a,b)
display("text/plain",v)
println()
v = evaluate(polynomial(),a,b)
display("text/plain",v)
println()
v = evaluate(rbf(),a,b)
display("text/plain",v)
println()

