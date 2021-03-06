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
    rbf(width::Float64=1.)  = new("RBF", width)
end

"""
  Calculate the matrix of distance squared of each data point from all the others, usually
  used with rbf kernel, but doesn't depend on kernel parameters. Added net::Kernel for 
  consistency only. 
"""
function _distance(net::Kernel , x1:: Array{Float64,2}, x2:: Array{Float64,2})
    dist = sum(x1.^2, dims=2) * ones(1,size(x2,1)) +
           ones(size(x1,1),1) * sum(x2.^2,dims=2)' - 2*x1*x2'    
end 


function evaluate(net::rbf, x1:: Array{Float64,2}, x2:: Array{Float64,2})  
     K = exp.(-_distance(net,x1,x2)/(net.width^2))
end 

"""
  Generates scaled width for a given dataset. It is the norm of the standard
  deviation across all dimension. if a vector (range) is added in the input argument
  it generate this same range but multiplied by the norm of the standard deviation

"""
function generate_std_width(ker::rbf, x::Array{Float64,2}, range::Vector{Float64}=zeros(0))
    if length(range)==0 
      norm(std(x,dims=1))
    else 
      norm(std(x,dims=1))*range  
    end
end

 
#a = rand(3,2)
## println(generate_std_width(a))
## println(generate_std_width(a, exp10.(-2:.1:2) ))

# b = rand(3,2)

# v = evaluate(linear(),a,b)
# display("text/plain",v)
# println()
# v = evaluate(polynomial(),a,b)
# display("text/plain",v)
# println()
# v = evaluate(rbf(),a,b)
# display("text/plain",v)
# println()
