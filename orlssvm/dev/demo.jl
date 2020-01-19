include("lssvm.jl");
using DelimitedFiles

#------------- banana set 
data = readdlm("../data/banana_data1000.csv",',')
y = data[:,1]
x = data[:,2:end] 

net = lssvm()
println(size(x))
@time net.train(x, y)
#println(net.alpha, net.bias)
println(sum(net.alpha))
y2 = net.predict(x)
dy = y2-y
print(mean(abs.(dy))," ", std(abs.(dy)))
using Plots
histogram(dy)
