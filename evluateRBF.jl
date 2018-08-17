function evaluateRBF(x,y,sigma=1)
  n1,m1 = size(x);
  n2,m2 = size(y);
  K = zeros(n1,n2);
  sig2 = sigma^2; 
  if (m1!=m2) 
    print("feature dimension must be the same");
	exit(1);
  else
     for i in 1:n1
	     for j in 1:n2
		    K[i,j] = exp( -sum((x[i,:]-y[j,:]).^2)/sig2)		
	     end
     end
  end
  return K;
end  