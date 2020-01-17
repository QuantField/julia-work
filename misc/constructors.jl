
struct comp 
    x::Float64
    y::Float64
    comp(x::Float64=0., y::Float64=0.) = new(x,y)
end 

z = comp(2.,3.)
println(z.x, "  ", z.y)
z = comp()
println(z.x, "  ", z.y)
println()

# ----------------  internal constructor 2
struct comp 
    x::Float64
    y::Float64
    function comp(x::Float64, y::Float64)
        println("Complex number created") 
        new(x,y)
    end
end 

z = comp(2.,3.)
println(z.x, "  ", z.y)
println()

# ---------------- internal constructor 2
mutable struct comp2 
    x::Float64
    y::Float64
    function comp2(x::Float64, y::Float64)
        println("Complex number created") 
        self = new() # self is arbitrary name
        self.x = x 
        self.y = y 
        self  
    end
end 

z = comp2(2.,3.)
println(z.x, "  ", z.y)
println()

# ---------------- default constructor
struct comp 
    x::Float64
    y::Float64    
end 

z = comp(2.,3.)
println(z.x, "  ", z.y)
println()

#---------------- external constructors
struct comp 
    x::Float64
    y::Float64    
end 
#
comp(x::Float64)=comp(x,0.)
comp() = comp(0., 0.)

z = comp(2.,3.)
println(z.x, "  ", z.y)
z = comp()
println(z.x, "  ", z.y)