
workspace(); # clear
cd("C:\\KS_temp\\julCode\\");
include("lssvmReg.jl");

 
#------------- Sinc data --------- 
 data = readcsv("Sinc.csv");
 y = data[:,3];
 x = data[:,1];
 net = lssvmReg("rbf",.1);
 net.setRBFWidth(1.);
 net.train(x,y);

#data = readcsv("LongLat.csv");
#I = randperm(size(data,1));
#Ind = I[1:1000];
#x = data[Ind ,1:2];
#y = data[Ind ,3];
#net = lssvmReg("linear",.1);
#net.train(x,y);
#net.press();
#OptimNet = net.optimise();

 
 
 println("tuning regularisation parameter :")
 Mu = 10.^[-3:.1:1.5];
 PRESS = net.tuneRegularisationParameter(Mu);
 optIndex = find(x->x==minimum(PRESS), PRESS);
 MuBest =  norm(Mu[optIndex]); # norm to convert form array to float
 PrBest = norm(PRESS[optIndex]);
 println("Best  Mu, PRESS = ",  MuBest,"   ", PrBest );
 println("Checking resutls ... seting the regularisation parameter with the best value)");
 net.setRegParam(MuBest)
 println("PRESS calculation (naive ...)");
 println(net.cvError(net.ntp))
 println("PRESS calculation (Closed Form ...)");
 print(net.press())
 
 
 # example 2 
 net2 = lssvmReg("rbf",.1);
 net2.setRBFWidth(1.);
 net2.train(x,y);
 println("\n\n------------------------");
 net2.optimalRegularisation(10.^[-3:.1:1.5]);
 println("------------------------");
 println("Polynomial kernel.."); 
 net2.setKernelType("polynomial");
 net2.setPolyParams(2.,1.);
 net2.optimalRegularisation(10.^[-3:.1:3]);
 net2.printInfo();
 
 # example 3 
 println("\n\n------------------------");
 # Full optimisation width and mu
 optNet = net.optimise();
 net.printInfo()
 optNet.printInfo()
 
 
