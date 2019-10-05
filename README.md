# SDPLib Importer

This helper function reads the problem data specified in SDPA sparse file format, transforms and saves the problem data into the easier to handle Julia Data Format (JLD).
The benchmark problems are provided in the SDPLib 1.2 (a library of semidefinite programming test problems) by Brian Borchers. They are availabe for download: [http://infohost.nmt.edu/~borchers/sdplib.html](http://infohost.nmt.edu/~borchers/sdplib.html).

## Prerequisites

- The code is written for Julia v1.0
- You need the `FileIO` and `JLD2` package to handle the Julia Data Format (JLD2). To get it simply type `add ("JLD2")`.

### Installing / Using

- Clone the repository to your local machine.
- Add the original SDPLib 1.2 problem files to a folder `/sdplib` (or edit the path inside SDPLib_Importer.jl).
- Run the `SDPLib_Importer.jl` file. (This will create .jld2 files inside the /sdplib/ folder.)

### Testing
- The following is a short test script that loads a converted problem in `.jld2` format, solves the problem using `JuMP` and the `COSMO.jl` solver:
```julia
data = load("./sdplib/maxG11.jld2");
F = data["F"]
c = data["c"]
m = data["m"]
n = data["n"]
obj_true = data["optVal"]

# Describe primal problem using JuMP and solve with SCS Solver
model = JuMP.Model(with_optimizer(COSMO.Optimizer, verbose = true, decompose = true));
@variable(model, x[1:m]);
@objective(model, Min, c' * x);
@constraint(model, con1,  Symmetric(-Matrix(F[1]) + sum(Matrix(F[k + 1]) .* x[k] for k in 1:m))  in JuMP.PSDCone());
JuMP.optimize!(model);
```

## Authors

* **Michael Garstka**


## License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details.

## Questions / Bugs
- Please use the Issue Tracker to report bugs or to ask questions.
