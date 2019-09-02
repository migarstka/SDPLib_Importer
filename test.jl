# Quick test to make sure that import works as intended
# Solve problem defined by imported file using ConvexJL and SCS
# by Michael Garstka
# University of Oxford, Control Group
# January 2018
# updated in April 2019


# We work with a semidefinite programming problem that has been written
# in the following standard form:

# (P)    min c1*x1+c2*x2+...+cm*xm
#        st  F1*x1+F2*x2+...+Fm*xn-F0=X
#                                  X >= 0



using FileIO, COSMO, SparseArrays, LinearAlgebra, Test

# import data from .jld2 file and create variables
data = load("./sdplib/truss1.jld2");
F = data["F"]
c = data["c"]
m = data["m"]
n = data["n"]
obj_true = data["optVal"]

# Describe primal problem using JuMP and solve with SCS Solver
# model = JuMP.Model(with_optimizer(COSMO.Optimizer, verbose = true, decompose = true));
# @variable(model, x[1:m]);
# @objective(model, Min, c' * x);
# @constraint(model, con1,  Symmetric(-Matrix(F[1]) + sum(Matrix(F[k + 1]) .* x[k] for k in 1:m))  in JuMP.PSDCone());
# # JuMP.optimize!(model);

# # ws = backend(model).optimizer.model.optimizer.inner;

# solve with native interface

d = div(n * (n + 1), 2)
A_man = zeros(d, m)
# now manually create A and B
for (i, Fi) in enumerate(F[2:end])
  t = zeros(d)
  COSMO.extract_upper_triangle!(Fi, t, sqrt(2))
  A_man[:, i] = t
end

b_man = zeros(d)
COSMO.extract_upper_triangle!(-F[1], b_man, sqrt(2))


cs1 = COSMO.Constraint(A_man, b_man, COSMO.PsdConeTriangle)
model_direct = COSMO.Model();
assemble!(model_direct, spzeros(m, m), c, cs1, settings = COSMO.Settings(verbose = true, decompose = false));
res = COSMO.optimize!(model_direct);


