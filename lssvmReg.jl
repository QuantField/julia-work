type lssvmReg
   
   # parameters for RBF kernel
   sigma :: Float64 ;
   
   # regularisation parameter
   mu    :: Float64 ;   
   
   x     :: Array{Float64,} ; # multi dimensional array x[][]
   y     :: Array{Float64,1}; # one dimension array y[]
   ntp   :: Int64;
   alpha :: Array{Float64,1};
   bias  :: Float64;
   
   # parameters for Polynomial kernel
   pol_order :: Float64;
   pol_ofset :: Float64;
   
   standarized :: Bool;
   means       :: Array{Float64,1};
   stds        :: Array{Float64,1};
   
   KernelType :: String ; # "RBF", "LINEAR", "POLYNOMIAL" 
   
   train          :: Function
   evaluateKernel :: Function
   evaluateRBF    :: Function 
   test           :: Function  
   trainError     :: Function
   looResiduals   :: Function
   press          :: Function   
   copy           :: Function  
   looError       :: Function
   setRBFWidth    :: Function
   setPolyParams  :: Function 
   setKernelType  :: Function
   setRegParam    :: Function
   printKernelInfo:: Function
   printInfo      :: Function 
   initialize     :: Function  
   cvError        :: Function   
   standarize     :: Function   
   initialRBFWidh :: Function
   tuneRegularisationParameter :: Function
   optimalRegularisation :: Function
   optimise :: Function 
   R2       :: Function   
   RMSE     :: Function  
   residuals :: Function   
   
function lssvmReg(kernel :: String = "rbf", mu::Float64=0.1)
    this = new();	
	#this.initialize();
    A = strip(uppercase(kernel));
	if ( A in ("RBF", "LINEAR", "POLYNOMIAL" ))
	     this.KernelType = A;
	else	 
	      println("Only RBF, LINEAR, POLYNOMIAL are allowed");
    end	
     
    this.mu         = mu;
   
    # "Deep" copy constructor
	# must include other new fields
    this.copy =
    function()
		 cp       = lssvmReg(this.KernelType, this.mu);
		 cp.alpha = copy(this.alpha);
		 cp.ntp   = this.ntp;
		 cp.bias  = this.bias;
		 cp.x     = this.x;
		 cp.y     = this.y;
		 cp.sigma = this.sigma;
		 cp.mu    = this.mu
		 cp.KernelType = deepcopy(this.KernelType);
		 cp.pol_order = this.pol_order;
         cp.pol_ofset = this.pol_ofset;
     return cp;   
    end
   
    this.initialize =
    function()	       
         null = zeros(1);	
		 this.alpha = null ;
		 this.ntp   = 0.;
		 this.bias  = 0.;
		 this.x     = null ;
		 this.y     = null ;
		 this.sigma = 0.;
		 this.mu    = 0.;
		 this.KernelType = "Not set";
		 this.pol_order = 0.;
         this.pol_ofset = 0.;	
	end	 
   
    this.printInfo = 
    function()
		 this.printKernelInfo();
		 println(" Number of Training points   = ",this.ntp);
		 println(" alpha = ",pointer(this.alpha));
		 println(" bias  = ",this.bias);
		 println(" x     = ",pointer(this.x));
		 println(" y     = ",pointer(this.y));
		 println(" Regularisation parameter    = ",this.mu);	 
    end
      
    this.train = 
	function(x::Array{Float64,}, y:: Array{Float64,1})
		   n = length(y);
		   this.ntp = n;
		   this.x   = x; # shallow copy
		   this.y   = y; # shallow copy
		   K = this.evaluateKernel(x,x);
		   T = [K + mu*eye(n) ones(n,1); ones(1,n+1)];
		   T[n+1,n+1] =0;
		   tar   = [y;0];
		   Sol   = T\tar;
		   this.alpha = Sol[1:n];
		   this.bias  = Sol[n+1];
	end 
    
	this.evaluateRBF = 
	function(x1:: Array{Float64,},x2:: Array{Float64,}) 
		  K = sum(x1.^2,2)*ones(1,size(x2,1))+ones(size(x1,1),1)*sum(x2.^2,2)'-2*x1*x2';		 
          K = exp(-K/(this.sigma^2));
		  return K';
	end  
	
	this.initialRBFWidh = 
	function()
	    return norm(std(this.x,1));
	end
	

	# usage : bestmu , bestpress = <something>.tuneRegularisationParameter()
	this.tuneRegularisationParameter =
	function(Mu::Array{Float64,1})	   
	    y = this.y;       				
		lambda, V = eig(this.evaluateKernel(this.x,this.x));
		Vt_y   = V'*y;
		Vt_sqr = V'.^2;
		xi     = sum(V,1)';		
		xi2    = xi.^2;
		PRESS = zeros(size(Mu));
		for i in 1:length(Mu)		
			u     = xi./(lambda+Mu[i]);
			g     = lambda./(lambda+Mu[i]);
			sm    = -sum(xi2./(lambda+Mu[i]));						
			theta = Vt_y./(lambda+Mu[i])-(-sum(u.*Vt_y)/sm)*u;									
   		    h     = Vt_sqr'*g + (V*(u.*lambda)-1).*(V*u)/sm;		            
			f     = V*(lambda.*theta) + -sum(u.*Vt_y)/sm;
            loo_resid = (y - f)./(1-h); 			
			PRESS[i] = sum(loo_resid.^2);	
            @printf("Mu = %4.6f  PRESS = %f\n", Mu[i], PRESS[i]);			
		end
		return PRESS;
	end		     

    # find best regularistaion parameter and retrain.
    this.optimalRegularisation =
    function(Mu::Array{Float64,1})	    	    
		PRESS    = this.tuneRegularisationParameter(Mu);
        optIndex = find(x->x==minimum(PRESS), PRESS);
        MuBest   =  norm(Mu[optIndex]); # norm to convert form array to float
        PrBest   = norm(PRESS[optIndex]); 
        this.setRegParam(MuBest);
		this.train(this.x, this.y);
        println("Optimised.");
    end
    
	# applies only to RBF
	this.optimise =
    function()
	    _lsvm = lssvmReg("rbf",.1);
        Sig = this.initialRBFWidh()*10.^[-2:.05:2]; 
		Params = zeros(length(Sig),2);
		Mu = 10.^[-3:.1:2];
		PRESS = zeros(size(Mu));
		x1 = this.x;
		y = this.y;       				
		K0 = sum(x1.^2,2)*ones(1,size(x1,1))+ones(size(x1,1),1)*sum(x1.^2,2)'-2*x1*x1';
		OvPress = Inf;
		bestSigma = 0;
		bestMu  = 0;
		for p in 1:length(Sig)   
			lambda, V = eig(exp(-K0/(Sig[p]^2)));
			Vt_y   = V'*y;
			Vt_sqr = V'.^2;
			xi     = sum(V,1)';		
			xi2    = xi.^2;		
            press = Inf;			
			for i in 1:length(Mu)		
				u     = xi./(lambda+Mu[i]);
				g     = lambda./(lambda+Mu[i]);
				sm    = -sum(xi2./(lambda+Mu[i]));						
				theta = Vt_y./(lambda+Mu[i])-(-sum(u.*Vt_y)/sm)*u;									
				h     = Vt_sqr'*g + (V*(u.*lambda)-1).*(V*u)/sm;		            
				f     = V*(lambda.*theta) + -sum(u.*Vt_y)/sm;
				loo_resid = (y - f)./(1-h); 			
				tmp = sum(loo_resid.^2);	
                if (tmp<press)
                   press = tmp;
                   mu    = Mu[i];
                end				   
		    end
			@printf("Sigma = %4.6f  mu = %4.6f   PRESS = %f\n",Sig[p], mu, press);
			if (press<OvPress)
                OvPress = press;
                bestSigma = Sig[p];
                bestMu    = mu;
            end				
		end	
		@printf("\nSigma = %f   mu = %f   PRESS = %f \n",bestSigma,bestMu,  OvPress);
		_lsvm.setRBFWidth(bestSigma);
		_lsvm.setRegParam(bestMu);
		println("Trainin with best parameters");
		_lsvm.train(this.x, this.y);
		return _lsvm;
	end	
	
	this.evaluateKernel = 
	function(x1:: Array{Float64,},x2:: Array{Float64,}) 
	    this.KernelType = uppercase(strip(this.KernelType));
	    if (this.KernelType=="RBF")
		    return this.evaluateRBF(x1,x2);
		elseif 	(this.KernelType=="POLYNOMIAL")
		    return   (x2*x1' + this.pol_ofset).^this.pol_order;
	    else 
            return x2*x1';
        end
    end		  
   
   this.test = 
   function(xTest:: Array{Float64,})
        return this.evaluateKernel(this.x,xTest)*this.alpha + this.bias
   end 	
   
   this.residuals =
   function()
       yhat = this.test(this.x);	 
	   return  this.y -yhat;
   end	   
   
   this.looResiduals =
   function()
        n = this.ntp;
        K = this.evaluateKernel(this.x,this.x);	       
		H        = [K   ones(n,1); zeros(1,n+1)]*inv([K+this.mu*eye(n) ones(n,1); ones(1,n) 0]);
		yhat     = H*[y;0];
		return (y-yhat[1:n])./(1-diag(H)[1:n]);
   end   
   
   this.press =
   function()
     r = this.looResiduals();
	 return dot(r,r);
   end  
	
	this.cvError = 
    function(folds::Int )        
	    netCV = this.copy();
		n   = net.ntp;
		pat = randperm(n);
        partition = [1:n]%folds;		;
	    err = 0.;
        for i=0:folds-1
		   
		   testIndex  = find(x->x==i,partition);
		   trainIndex = find(x->x!=i,partition);  
		   
		   xtrain = this.x[pat[trainIndex],:]; ytrain = this.y[pat[trainIndex]];
		   xtest  = this.x[pat[testIndex],:];  ytest  = this.y[pat[testIndex]]; 
		    
		   netCV.train(xtrain,ytrain);
		   yhat = netCV.test(xtest);   		   
		   resid = yhat - ytest;			  
           err  += dot(resid,resid);
		end   
   	 
		return err;	 	
	end
	
	
	this.setRegParam = 
	function(mu :: Float64)
	   this.mu = mu;
	end   
	
	
	this.setKernelType = 
	function(s::String)
	  A = strip(uppercase(s));
	  if ( A in ("RBF", "LINEAR", "POLYNOMIAL" ))
	     this.KernelType = A;
	  else	 
	      println("Only RBF, LINEAR, POLYNOMIAL are allowed");		  
      end
    end 

    this.printKernelInfo =
    function() 
	    println("Kernel = ",this.KernelType);
	    if (this.KernelType=="RBF")
		    println(" RBF Width : sigma = ", this.sigma);			
		elseif 	(this.KernelType=="POLYNOMIAL")
		    println(" order : pol_order = ", this.pol_order);
            println(" ofset : pol_ofset = ", this.pol_ofset);			
	    else
        end
    end		
	
	this.setPolyParams =
    function(order :: Float64, ofset::Float64 )
	  if (this.KernelType == "POLYNOMIAL")
        this.pol_order = order;
        this.pol_ofset = ofset ;
	  else
        println("Wrong Kernel");
      end		
    end  	   

    this.setRBFWidth =
	function(sigma::Float64) 
	  if (this.KernelType == "RBF")
        this.sigma = sigma;        
	  else
        println("Wrong Kernel");
      end		
	end	
	
	
	# need some work... because we this.x is shallow copy of x (from the training).. Pb..
	this.standarize=
	function()
	  this.means = mean(this.x,1);
	  this.stds  = std(this.x,1);
	  for i=1:length(this.means)
	    this.x[:,i] = (this.x[:,i]-this.means[i])/this.stds[i]; 
	  end
      this.standarized = true;	  
	  println("warning : data x has changed, it is standarized");
	end
	
	
	this.R2 = 
    function()	 
      return 1-sum(this.residuals().^2)/sum((this.y- mean(this.y)).^2); 
    end 
	
	
	this.RMSE = 
	function()
	   return  sqrt(mean(this.residuals().^2));
	end   
	
	
   return this;
   
end 


end






