abstract type Vehicle end

make(v::Vehicle) = v.make
model(v::Vehicle) = v.model 


mutable struct car <: Vehicle
    make::String 
    model::String 
    car(make::String, model::String) = new(make, model)
end

fiesta = car("Ford","Fiesta")
println(make(fiesta))
println(model(fiesta))

# composition
mutable struct truck 
    veh::car
    weight::Float64 
    truck(make::String, model::String, weight::Float64) = new(car(make, model),weight)   
end

t1 = truck("Ford", "X1", 50000.)












                  





