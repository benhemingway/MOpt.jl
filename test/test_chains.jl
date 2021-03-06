module TestChain

using FactCheck,MOpt,Lazy,DataFrames



# TESTING Chains
# ==============
pb   = Dict( "a" => [0.3; 0;1] , "b" => [0.4;0;1] )
moms = DataFrame(name=["alpha";"beta";"gamma"],value=[0.8;0.7;0.5],weight=rand(3))

facts("Testing Default Chains constructor") do
	
	mprob = MProb() 
	addParam!(mprob,Dict("c" => 0.1)) 
	addSampledParam!(mprob,pb) 
	addMoment!(mprob,moms)

	L = 9
	chain = Chain(mprob,L)

	@fact chain.i => 0 

	context("length of members") do

		# test that all member except i are L long
		@fact length(chain.infos[:evals])  --> L
		@fact length(chain.infos[:accept]) --> L
		for nm in MOpt.ps2s_names(mprob)
			@fact length(chain.parameters[symbol(nm)]) --> L
		end
		for nm in MOpt.ms_names(mprob)
			@fact length(chain.moments[symbol(nm)]) --> L
		end
	end

	context("get correct dataframe labels") do
		@fact names(MOpt.parameters(chain)) --> MOpt.ps2s_names(mprob)
		for nm in MOpt.ms_names(mprob)
			@fact nm in names(MOpt.moments(chain))[2:end] --> true
		end
	end
end

facts("testing Chain/MChain methods") do

	context("testing getindex(chain,i)") do

		mprob = @> MProb() addSampledParam!(pb) addMoment!(moms) addEvalFunc!(MOpt.Testobj2)

		L = 9	# length of chain
		chain = Chain(mprob,L)

		i = rand(1:L)

		x = allstats(chain,i)

		@fact isa(x,DataFrame) --> true
		@fact nrow(x) --> 1


	end

	context("testing getindex(chain,i::Range)") do

		mprob = @> MProb() addSampledParam!(pb) addMoment!(moms) addEvalFunc!(MOpt.Testobj)

		L     = 9	# length of chain
		chain = Chain(mprob,L)

		i = 3:L
		x = allstats(chain,i)
		
		@fact isa(x,DataFrame) --> true
		@fact nrow(x) --> length(i)

	end
	
	context("test appendEval!(chain)") do

		mprob = @> MProb() addSampledParam!(pb) addMoment!(moms) addEvalFunc!(MOpt.Testobj2)
		ev = Eval(pb,moms)
		ev = MOpt.Testobj2(ev)

		for (k,va) in ev.params
			ev.params[k] = va + 1.1
		end

		L = 9
		chain = Chain(mprob,L)
		# set i to 1 to test this:
		chain.i = 1

		# verify values are zero:
		@fact all(chain.infos[chain.i,:evals] == 0.0) --> true
		# verify params are zero
		for ic in 1:ncol(chain.parameters)
			@fact chain.parameters[chain.i,ic][1] --> 0.0
		end

		# update chain with v
		MOpt.appendEval!(chain,ev,true,1.0)

		# verify new values on chain
		@fact chain.infos[:evals][1] --> ev.value
		@fact chain.infos[:accept][1] --> true
		for nm in MOpt.ps2s_names(mprob)
			@fact chain.parameters[chain.i,symbol(nm)][1] --> ev.params[nm]
		end
	end
end


facts("testing collectFields and fillinFields functions") do
	
	mprob = @> MProb() addSampledParam!(pb) addMoment!(moms) addEvalFunc!(MOpt.Testobj2)
	chain = Chain(mprob,10)

	context("collectFields") do

		df= parameters(chain,1)
		@fact isa(df,DataFrame) --> true
		@fact df[:a] --> [0.0]
		@fact df[:b] --> [0.0]

	end
end


facts("testing dataframe save and read") do




end



end # module 






