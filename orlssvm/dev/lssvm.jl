using Printf

include("kernels.jl")


reg_vals =  exp10.(-3:0.1:2)
width_vals = exp10.(-2:0.1:1)

function _eye(n::Int)  
   Matrix{Float64}(I,n,n) 
end

mutable struct  lssvm   
    kernel:: Kernel 
    mu    :: Float64    
    x     :: Array{Float64,2} 
    y     :: Vector{Float64} 
    ntp   :: Int64  # number of training points
    alpha :: Vector{Float64}
    bias  :: Float64   
    lssvm(kernel::Kernel=rbf(), mu::Float64=0.1) = new(kernel, mu)
end
   

function train(net::lssvm, x::Array{Float64,}, y:: Vector{Float64})
    n = length(y)
    net.ntp = n
    net.x   = x
    net.y   = y   
    T = [evaluate(net.kernel, x,x) + net.mu*_eye(n) ones(n,1); ones(1,n+1)]
    T[n+1, n+1] =0
    tar   = [y; 0]
    Sol   = T\tar
    net.alpha = Sol[1:n]
    net.bias  = Sol[n+1]
end

function predict(net::lssvm, xt:: Array{Float64, 2})
    evaluate(net.kernel, net.x, xt)*net.alpha .+ net.bias
end

function loo_residuals(net::lssvm, x::Array{Float64, 2}, y::Vector{Float64} )
    n = net.ntp
    K = evaluate(net.kernel, x, x)       
    H = [K   ones(n,1); zeros(1,n+1)]*inv([K + net.mu*_eye(n) ones(n,1); ones(1,n) 0])
    yhat = H*[y;0]
    r = (y-yhat[1:n])./(1 .- diag(H)[1:n])    
end  

function press(net::lssvm, x::Array{Float64, 2}, y::Vector{Float64} )
    r = loo_residuals(net, x, y)
    dot(r,r) 
end   

function loo_error(net::lssvm, x::Array{Float64, 2}, y::Vector{Float64} )
    err = sign.( map( t-> t<0, 1 .- y.*loo_residuals(net,x,y)))    
    mean(err)
end   

function optimal_regularisation(net::lssvm, x::Array{Float64, 2},  y::Vector{Float64},
                                mu_vals::Vector{Float64}=reg_vals )     
    lambda, V = eigen(evaluate(net.kernel, x,x))
    Vt_y   = V'*y
    Vt_sqr = V'.^2
    xi     = sum(V, dims=1)'   
    xi2    = xi.^2
    PRESS = Float64[]
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
    press, ind = findmin(PRESS)
    mu_vals[ind], press  
end        


# function opt_rbf_regularisation(net::lssvm, x::Array{Float64, 2},  y::Vector{Float64},
#                                 mu_vals::Vector{Float64}=reg_vals, 
#                                 width_range::Vector{64}=zeros(0) )   
    
#     ker  = rbf()
#     if length(width_range)==0
#       rbf_width_values = generate_std_width(ker, x, width_vals)
#     else 
#       rbf_width_values = width_range
#     end


#         Sig = this.initialRBFWidh()*10.^[-2:.05:2]; 
#     Params = zeros(length(Sig),2);
    
#     PRESS = zeros(size(Mu));
#     x1 = this.x;
#     y  = this.y;               
#     K0 = sum(x1.^2, dims=2) * ones(1,size(x2,1)) +
#          ones(size(x1,1),1) * sum(x2.^2,dims=2)' - 2*x1*x2'
#     OvPress = Inf;
#     bestSigma = 0;
#     bestMu  = 0;
#     for sigma in rbf_width_values  
#       lambda, V = eig(exp(-K0/(sigma^2)));
#       Vt_y   = V'*y;
#       Vt_sqr = V'.^2;
#       xi     = sum(V,1)';   
#       xi2    = xi.^2;   
#       press = Inf;      
#       for i in 1:length(Mu)   
#         u     = xi./(lambda+Mu[i]);
#         g     = lambda./(lambda+Mu[i]);
#         sm    = -sum(xi2./(lambda+Mu[i]));            
#         theta = Vt_y./(lambda+Mu[i])-(-sum(u.*Vt_y)/sm)*u;                  
#         h     = Vt_sqr'*g + (V*(u.*lambda)-1).*(V*u)/sm;                
#         f     = V*(lambda.*theta) + -sum(u.*Vt_y)/sm;
#         loo_resid = (y - f)./(1-h);       
#         tmp = sum(loo_resid.^2);  
#                 if (tmp<press)
#                    press = tmp;
#                    mu    = Mu[i];
#                 end          
#         end
#       @printf("Sigma = %4.6f  mu = %4.6f   PRESS = %f\n",Sig[p], mu, press);
#       if (press<OvPress)
#                 OvPress = press;
#                 bestSigma = Sig[p];
#                 bestMu    = mu;
#             end       
#     end 
#     @printf("\nSigma = %f   mu = %f   PRESS = %f \n",bestSigma,bestMu,  OvPress);
#     _lsvm.setRBFWidth(bestSigma);
#     _lsvm.setRegParam(bestMu);
#     println("Trainin with best parameters");
#     _lsvm.train(this.x, this.y);
#     return _lsvm;
