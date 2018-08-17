
workspace(); # clear
cd("C:\\KS_temp\\julCode\\");
include("lssvm.jl");

#--------------- Kaggle set 
# data = readcsv("KaggleTrainNoHead.csv");
# y = data[:,1];
# y[find(x->x==0,y)]=-1;
# x = data[:,2:end];
# net = lssvm("rbf",0.31029902868595216); #optim params
# net.setRBFWidth(9.553806751325649);
 
#------------- banana set 
 data = readcsv("banana_data1000.csv");
 y = data[:,1];
 x = data[:,2:end]; 
 net = lssvm("rbf",.1);
 net.setRBFWidth(1.);
 
 net.printKernelInfo(); 
 net.train(x,y);
 println("Train Error = ",net.trainError());
 println("LOO   Error = ",net.looError());
 println("PRESS       = ",net.press());
 println("CV CLASSIFICATION Error    = ",net.cvError("class",5));
 println("CV SUM OF SQUARED ERROS    = ",net.cvError("msse",5));

 
 println();
 net.setKernelType("linear");
 net.printKernelInfo();
 net.train(x,y); 
 println("Train Error = ",net.trainError());
 println("LOO   Error = ",net.looError());
 println("PRESS       = ",net.press());
 println("CV CLASSIFICATION Error    = ",net.cvError("class",5));
 println("CV SUM OF SQUARED ERROS    = ",net.cvError("msse",5));
 
 println(); 
 net.setKernelType("polynomial");
 net.setPolyParams(3.,1.);
 net.printKernelInfo();
 net.train(x,y); 
 println("Train Error = ",net.trainError());
 println("LOO   Error = ",net.looError());
 println("PRESS       = ",net.press());
 println("CV CLASSIFICATION Error    = ",net.cvError("class",5));
 println("CV SUM OF SQUARED ERROS    = ",net.cvError("msse",5));
 
 