include("kernels.jl")

struct  lssvm
   
    # regularisation parameter
    mu    :: Float64    
    x     :: Array{Float64,2}  # multi dimensional array x[][]
    y     :: Array{Float64,1} # one dimension array y[]
    ntp   :: Int64
    alpha :: Array{Float64,1}
    bias  :: Float64

    train  :: Function
    predict:: Function  
 
   
    function lssvm(kernel::Kernel=rbf(), mu::Float64=0.1)
       self = new()
       self.mu = mu
        
          
       self.train = 
       function (x::Array{Float64,2}, y:: Array{Float64,1})
            train(self, x, y)
       end 
        
       self.predict = 
       function (xt:: Array{Float64, 2})
            predict(self, xt)
       end 	
       
       self
    end 

end

function train(net::lssvm, x::Array{Float64,}, y:: Array{Float64,1})
    n = length(y)
    net.ntp = n
    net.x   = x # shallow copy
    net.y   = y # shallow copy    
    T = [net.kernel.evaluate(x,x) + mu*eye(n) ones(n,1); ones(1,n+1)]
    T[n+1,n+1] =0
    tar   = [y; 0]
    Sol   = T\tar
    net.alpha = Sol[1:n]
    net.bias  = Sol[n+1]
end

function predict(net::lssvm, xt:: Array{Float64, 2})
    net.kernel.evaluate(net.x, xt)*self.alpha .+ self.bias
end





   # self.trainError =
   # function()
   #     yhat = self.test(self.x)
   #     # Matlab equiv length(sign(yhat)!=sign(y))
   #     return length(find(x->x!=0, sign(yhat)-sign(y)))/length(yhat)
   # end     
   
   # self.looResiduals =
   # function()
   #      n = self.ntp
   #      K = self.evaluateKernel(self.x,self.x)         
   #      H        = [K   ones(n,1) zeros(1,n+1)]*inv([K+self.mu*eye(n) ones(n,1) ones(1,n) 0])
   #      yhat     = H*[y0]
   #      return (y-yhat[1:n])./(1-diag(H)[1:n])
   # end   
   
   # self.press =
   # function()
   #   r = self.looResiduals()
   #   return dot(r,r)
   # end  

   # self.looError =
   # function()
   #      # matlab equiv find[sign(1-y.*loo)<0]
   #      err = find(e->e<0,sign(1-self.y.*self.looResiduals()))  
   #      return length(err)/self.ntp
   #  end
    




