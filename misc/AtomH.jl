
using Roots

immutable radWaveFunc
    n     :: Int
	l     :: Int
	E     :: Float64
	r     :: Array{Float64,1}
	value :: Array{Float64,1}
end	


#(
 *
 * solves Shrodinger equation for Hydrogenoids, Z>1 including Hydrogen Z=1
 *
 *
 )#
# a = collect(linspace(0.,1.,101));
type AtomH
	N    :: Int
	h    :: Float64	
	Rmax :: Float64
	Sol  :: Array{Float64,1} # Solution : Psi = r*Sol
	r    :: Array{Float64,1}
	rho  :: Array{Float64,1}
	wave :: Array{Float64,1} # Psi
	Vcoulomb     :: Array{Float64,1} # -Z/r
	Vcentrifugal :: Array{Float64,1}  #0.5l(l+1)/r^2
	Vext         :: Array{Float64,1}  # Total Potential = Vcoulomb + Vcentrifugal
	K :: Array{Float64,1}
	EnergyBrackets :: Array{Float64,}
	EnergyLevels :: Int
	E:: Float64
	Z:: Int
	WaveFuncs :: Array{radWaveFunc,1};

	getSpectrum :: Function
	Numerov :: Function
	F  :: Function
	
    function AtomH( N::Int, Z::Int,  Rmax::Float64)
     	this         = new()
		this.N , this.Z, this.Rmax  = N, Z, Rmax;
		h            = Rmax/N;
		rho          = zeros(N+1);
		Sol          = zeros(N+1);          
		r            = collect(0.:h:Rmax);
		this.Vcoulomb   = -Z./r;
		
	this.Numerov =
    function(E::Float64)	   
	    this.E = E0; # E0 is negative 
	    K    = 2.*(E-this.Vext)
	    C    = h*h/12.
	    alph = sqrt(-2*E0)
		Sol[N+1] = exp(-alph*r[N+1]) #0; // r[N]*Math.exp(-Z*r[N]) ;  // Sol(xb) = 0;
		Sol[N]   = exp(-alph*r[N]) #//1e-8; // r[N-1]*Math.exp(-Z*r[N-1]) ; //1e-6; //   
		#Sol[N]   =   r[N]*Math.exp(-Z*r[N]) ;
		#Sol[N-1] =   r[N-1]*Math.exp(-Z*r[N-1]) ;    
	    for i = this.N:-1:2
			Sol[i-1] = ( 2*(1.- 5.*C*K[i])*Sol[i] -
					(1. + C*K[i+1] )*Sol[i+1] )/(1.+C*K[i-1])
		end
    end		
		

    this.F = 
    function(E::Float64)	
        this.Numerov(E)
        return Sol[1] //Sol[N+1]; this for Numerov starting from the Left
    end		
		
		
	this.getSpectrum =
    function(Nmax::Int)	
		#int Nmax = 4;
		for l = 0:Nmax-1 		
			println("l = ",l);		
			this.Vext    = this.Vcoulomb + (0.5*l*(l+1))./(this.r).^2;
			this.Vext[1] = this.Vext[2] # Inf at 0;
			
			double Emin = -0.5*Z*Z/((l+1)*(l+1))-3;
			double Emax = 0;
			
			spectrum  = fzeros(this.F, Emin, Emax)
			
		    for i=1:length(spectrum)
				En = spectrum[i];
				Numerov(En); # get wave function  in Sol
				n = i+l;
				wave = radWaveFunc(n,l,En,copy(this.r),copy(Sol))
				@printf("n =%d    E =%14.10f  \n", n, E)
				# sort with respect to n
			end	
		end		
	end	
       
    return this   
	   
    end
end	

     







