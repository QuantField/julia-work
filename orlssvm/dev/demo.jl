include("lssvm.jl");
using DelimitedFiles

#------------- banana set 
data = readdlm("../data/banana_data1000.csv",',')
y = data[:,1]
x = data[:,2:end] 

net = lssvm()
println("Training...")
@time train(net,x, y)
yhat = predict(net, x)
println("Training Error      = ", mean(sign.(yhat).!=sign.(y)))          
println("PRESS (Statistic)   = ", press(net, x,y))
println("Leave One Out Error = ", loo_error(net,x,y))

reg_vals =  exp10.(-5:0.1:2)

best_mu, best_press = optimal_regularisation(net, x, y, reg_vals)

println("\nUsing best regularisation parameter:")
net.mu = best_mu
println("Training...")
@time train(net, x, y)
yhat = predict(net, x)
println("Training Error      = ", mean(sign.(yhat).!=sign.(y)))          
println("PRESS (Statistic)   = ", press(net, x,y))
println("Leave One Out Error = ", loo_error(net,x,y))

