include("kernels.jl")
include("lssvm.jl")
using DelimitedFiles

#------------- banana set 
data = readdlm("../data/banana_data1000.csv",',')
y = data[:,1]
x = data[:,2:end] 

net = lssvm(rbf(1.), 0.1)

println("Training...")
@time train(net,x, y)
yhat = predict(net, x)
println("Training Error      = ", mean(sign.(yhat).!=sign.(y)))          
println("PRESS (Statistic)   = ", press(net, x,y))
println("Leave One Out Error = ", loo_error(net,x,y))


println("\nUsing best regularisation parameter:")
reg_vals =  exp10.(-5:0.1:2)
@time best_mu, best_press = optimal_regularisation(net, x, y, reg_vals)
net.mu = best_mu
println("Training...")
@time train(net, x, y)
yhat = predict(net, x)
println("Training Error      = ", mean(sign.(yhat).!=sign.(y)))          
println("PRESS (Statistic)   = ", press(net, x,y))
println("Leave One Out Error = ", loo_error(net,x,y))


println("\nUsing best rbf width and regularisation parameter:")
net = opt_rbf_regularisation( net, x,  y) #, reg_vals, width_vals)
println("\nRetraining with Optimal parameters")
@time train(net,x, y)
yhat = predict(net, x)
println("Training Error      = ", mean(sign.(yhat).!=sign.(y)))          
println("PRESS (Statistic)   = ", press(net, x,y))
println("Leave One Out Error = ", loo_error(net,x,y))
exit(0)
