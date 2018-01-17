# Quick test to make sure that import works as intended
# Solve problem defined by imported file using ConvexJL and SCS
# by Michael Garstka
# University of Oxford, Control Group
# January 2017

workspace()
using Convex, SCS, JLD
using Base.Test

# import data from .jld file and create variables
data = JLD.load("./sdplib/truss1.jld")
F = data["F"]
c = data["c"]
m = data["m"]
n = data["n"]
optVal = data["optVal"]


# Describe problem using ConvexJL and solve with SCS Solver
x = Variable(m)
X = Variable(n,n)
problem = minimize(c'*x)
constraint1 = sum(F[i+1]*x[i] for i=1:m) - F[1] == X
constraint2 = isposdef(X)
problem.constraints += [constraint1,constraint2]
solve!(problem,SCSSolver(verbose=false))

# check that the objective values match
@test norm(problem.optval - optVal) <= 1e-3
