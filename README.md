# SDPLib Importer

This helper function reads the problem data specified in SDPA sparse file format, transforms and saves the problem data into the easier to handle Julia Data Format (JLD).
The benchmark problems are provided in the SDPLib 1.2 (a library of semidefinite programming test problems) by Brian Borchers. They are availabe for download: [http://infohost.nmt.edu/~borchers/sdplib.html](http://infohost.nmt.edu/~borchers/sdplib.html).

## Prerequisites

- The code is written for Julia v0.6. 
- You need the JLD package to handle the Julia Data Format (JLD). To get it simply type ``Pkg.add("JLD")``.

### Installing / Using

- Clone the repository to your local machine.
- Add the original SDPLib 1.2 problem files to a folder "/sdplib" (or edit the path inside SDPLib_Importer.jl).
- Run the SDPLib_Importer.jl file. (This will create .jld files inside the /sdplib/ folder.)

### Testing 
- The following is a short test script that loads a converted problem in .jld format, solves the problem using ConvexJL and the SCS solver, and compares the calculated objective value to the true value provided in the problem description.
```julia
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
```

## Authors

* **Michael Garstka**


## License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details.

## Questions / Bugs
- Please use the Issue Tracker to report bugs or to ask questions.
