using Printf

include("kernels.jl")


reg_vals =  exp10.(-3:0.1:2)

mutable struct  lssvm
   
    kernel:: Kernel 
    mu    :: Float64    
    x     :: Array{Float64,2} 
    y     :: Vector{Float64} 
    ntp   :: Int64  # number of training points
    alpha :: Vector{Float64}
    bias  :: Float64

    train  :: Function
    predict:: Function  
    loo_residuals:: Function 
    loo_error::Function 
    press::Function
    optimal_regularisation::Function
    _eye:: Function 
 
   
    function lssvm(kernel::Kernel=rbf(), mu::Float64=0.1)
       self = new() 
       self.mu = mu
       self.kernel = kernel
        
          
       self.train = 
       function (x::Array{Float64,2}, y:: Vector{Float64})
         train(self, x, y)
       end 
        
       self.predict = 
       function (xt:: Array{Float64, 2})  
         predict(self, xt)  
       end

       self.loo_residuals = 
       function (x::Array{Float64, 2}, y::Vector{Float64}) 
         loo_residuals(self,x,y)[1]          
       end

       self.press = 
       function (x::Array{Float64, 2}, y::Vector{Float64}) 
         loo_residuals(self,x,y)[2]         
       end
       
       self.loo_error=
       function (x::Array{Float64, 2}, y::Vector{Float64})
          loo_error(self,x,y)  
       end 

       self.optimal_regularisation = 
       function (x::Array{Float64, 2}, y::Vector{Float64}, 
                  mu_vals::Vector{Float64} = reg_vals )   
            optimal_regularisation(self, x, y, mu_vals)
       end
       #------------- Helper functions --------------#
       self._eye =  function(n::Int)  
           Matrix{Float64}(I,n,n) 
       end
         
       self
      end 
end



function train(net::lssvm, x::Array{Float64,}, y:: Vector{Float64})
    n = length(y)
    net.ntp = n
    net.x   = x
    net.y   = y   
    T = [net.kernel.evaluate(x,x) + net.mu*net._eye(n) ones(n,1); ones(1,n+1)]
    T[n+1, n+1] =0
    tar   = [y; 0]
    Sol   = T\tar
    net.alpha = Sol[1:n]
    net.bias  = Sol[n+1]
end

function predict(net::lssvm, xt:: Array{Float64, 2})
    net.kernel.evaluate(net.x, xt)*net.alpha .+ net.bias
end

function loo_residuals(net::lssvm, x::Array{Float64, 2}, y::Vector{Float64} )
    n = net.ntp
    K = net.kernel.evaluate(x, x)        
    H = [K   ones(n,1); zeros(1,n+1)]*inv([K + net.mu*net._eye(n) ones(n,1); ones(1,n) 0])
    yhat = H*[y;0]
    r = (y-yhat[1:n])./(1 .- diag(H)[1:n])
    r, dot(r,r) 
end  

function loo_error(net::lssvm, x::Array{Float64, 2}, y::Vector{Float64} )
    err = sign.( map( t-> t<0, 1 .- y.*loo_residuals(net,x,y)[1]))    
    mean(err)
end   

function optimal_regularisation(net::lssvm, x::Array{Float64, 2}, 
                                y::Vector{Float64},
                                mu_vals )     
    lambda, V = eigen(net.kernel.evaluate(net.x, net.x))
    Vt_y   = V'*y
    Vt_sqr = V'.^2
    xi     = sum(V, dims=1)'   
    xi2    = xi.^2
    PRESS = []
    for mu in mu_vals
      u     = xi./(lambda .+ mu)
      g     = lambda./(lambda .+ mu)
      sm    = -sum(xi2./( lambda .+ mu))            
      theta = Vt_y./(lambda .+ mu) + (sum(u.*Vt_y)/sm)*u 
      h     = Vt_sqr'*g + (V*(u.*lambda) .-1 ).*(V*u)/sm                
      f     = V*(lambda.*theta) .-sum(u.*Vt_y)/sm
      loo_resid = (y - f)./(1 .- h)       
      _press = sum(loo_resid.^2)
      push!(PRESS, _press)
      @printf("Mu = %4.6f  PRESS = %f\n", mu, _press);     
    end
    ind = argmin(PRESS)
    mu_vals[ind], PRESS[ind]  
end        