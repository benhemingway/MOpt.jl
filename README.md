

# MOpt.jl: Moment Optimization Library for [Julia](http://julialang.org)

[![Build Status](https://travis-ci.org/floswald/MOpt.jl.png?branch=master)](https://travis-ci.org/floswald/MOpt.jl)

This package provides a `Julia` infrastructure for *[Simulated Method of Moments](http://en.wikipedia.org/wiki/Method_of_simulated_moments)* estimation, or other problems where we want to optimize a non-differentiable objective function. The setup is suitable for all kinds of **likelihood-free estimators** - in general, those require evaluating the objective at many regions. The user can supply their own algorithms for generating successive new parameter guesses. We provide a set of MCMC template algorithms. The code can be run in serial or on a cluster.

[![acceptance rates](https://dl.dropboxusercontent.com/u/109115/MOpt.jl/acceptance.png)]()

## Installation

```julia
Pkg.clone("https://github.com/floswald/MOpt.jl")
```

## Detailed Documentation

[Documentation available on readthedocs.](http://moptjl.readthedocs.org/en/latest/)


## Example Usage of the BGP Algorithm

Baragatti, Grimaud and Pommeret (BGP) in ["Likelihood-free parallel tempring"](http://arxiv.org/abs/1108.3423) propose an approximate Bayesian Computation (ABC) algorithm that incorporates the parallel tempering idea of Geyer (1991). We provide the BGP algorithm as a template called `MAlgoBGP`. Here we use it to run a simple toy example.

```julia
using MOpt

# this is MOpt.serialNormal()

# data are generated from a bivariate normal
# with mu = [a,b] = [0,0]
# aim: 
# 1) sample [a',b'] from a space [-1,1] x [-1,1] and
# 2) find true [a,b] by computing distance(S([a',b']), S([a,b]))
#    and accepting/rejecting [a',b'] according to BGP
# 3) S([a,b]) returns a summary of features of the data

# initial value
pb    = Dict("p1" => [0.2,-2,2] , "p2" => [-0.2,-2,2] )
moms = DataFrame(name=["mu2","mu1"],value=[0.0,0.0],weight=ones(2))
mprob = MProb() 
addSampledParam!(mprob,pb) 
addMoment!(mprob,moms) 
addEvalFunc!(mprob,objfunc_norm)

# look at model slices
# fixes all but one parameter at a time and computes 30 points in it's range.
obj_slices = MOpt.slices(mprob,30)


# setup the options for a serial run
opts =Dict(
	"N"               => 1,							# number of MCMC chains
	"maxiter"         => 500,						# max number of iterations
	"savefile"        => joinpath(pwd(),"MA.h5"),	# filename to save results
	"print_level"     => 1,							# increasing verbosity level of output
	"maxtemp"         => 1,							# tempering of hottest chain
	"min_shock_sd"    => 0.1,						# initial sd of shock on coldest chain
	"max_shock_sd"    => 0.1,						# initial sd of shock on hottest chain
	"past_iterations" => 30,						# num of periods used to compute Cov(p)
	"min_accept_tol"  => 100000,					# ABC-MCMC cutoff for rejecting small improvements
	"max_accept_tol"  => 100000,					# ABC-MCMC cutoff for rejecting small improvements
	"min_disttol"     => 0.1,						# distance tol for jumps from coldest chain
	"max_disttol"     => 0.1,						# distance tol for jumps from hottest chain
	"min_jump_prob"   => 0.05,						# prob of jumps from coldest chain
	"max_jump_prob"   => 0.05)						# prob of jumps from hottest chain

# setup the BGP algorithm
MA = MAlgoBGP(mprob,opts)

# setup Lumberjack logging
# remove_truck("console")
# add_truck(LumberjackTruck(STDOUT,logmode),"serial-log")

# run the estimation
runMOpt!(MA)
fig = figure("parameter histograms") 
plt[:hist](convert(Array,MOpt.parameters(MA.MChains[1])),15)

```

<!-- [![objective slices](https://dl.dropboxusercontent.com/u/109115/MOpt.jl/slices_objective.png)]()
[![alpha slices](https://dl.dropboxusercontent.com/u/109115/MOpt.jl/slices_alpha.png)]()
[![beta slices](https://dl.dropboxusercontent.com/u/109115/MOpt.jl/slices_beta.png)]()
 -->



## Contributing

We encourage user contributions. Please submit a pull request for any improvements you would like to suggest, or a new algorithm you implemented. 

New algorithms:
*You can model your algo on the basis of `src/AlgoBGP.jl` - 
* your algorithm needs a storage system for chains, derived from the default type `Chain` in `src/chains.jl`
* you need to implement the function `computeNextIteration!( algo )` for your `algo`










