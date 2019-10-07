defmodule CustomGenExampleProper do
	use ExUnit.Case
	use PropCheck

	# property

	property "always works" do
		forall type <- term() do
			boolean(type)
		end
	end


	property "find all keys in a map enven when dupes are used", [:verbose] do
		forall kv <- list({key(), val()}) do
			m = Map.new(kv)
			for {k,_v} <- kv, do: Map.fetch!(m, k)
			uniques =
				kv |> List.keysort(0)
					 |> Enum.dedup_by(fn {x, _} -> x end)
			collect(true, {:dupes, to_range(5, length(kv) - length(uniques))})
		end
	end


	# make verbose for metrics
	property "collect 1", [:verbose] do
		forall bin <- binary() do
			#          test           metric
			collect(is_binary(bin), byte_size(bin))
		end
	end	


	# make verbose for metrics
	property "collect 2", [:verbose] do
		forall bin <- binary() do
			#   test        metric
			collect(is_binary(bin), to_range(10, byte_size(bin)))
		end
	end

	
	property "aggregate", [:verbose] do
		suits = [:club, :diamond, :heart, :spade]
		
		forall hand <- vector(5, {oneof(suits), choose(1,13)}) do
			# always pass
			aggregate(true, hand)
		end
	end


	property "profile 1", [:verbose] do
		forall profile <- [
			name: resize(10, utf8()),
			age: pos_integer(),
			bio: resize(350, utf8())
		] do
			name_len = to_range(10, String.length(profile[:name]))
			bio_len = to_range(300, String.length(profile[:bio]))
			aggregate(true, name: name_len, bio: bio_len)
		end
	end


	@doc """
	the ?SIZED(VarName, Expression) macro, which
	introduces the variable VarName into the scope of Expression , bound to the
	internal size value for the current execution. This size value changes with
	every test, so what we do with the macro is change its scale, rather than
	replacing it wholesale.
	"""
	property "profile 2", [:verbose] do
		forall profile <- [
			name: resize(10, utf8()),
			age: pos_integer(),
			# In this property, the bio string is specified to be thirty-five times larger than
			# the current size, which is implicitly the size value for name and age values.
			bio: sized(s, resize(s * 35, utf8()))
		] do
			name_len = to_range(10, String.length(profile[:name]))
			bio_len = to_range(300, String.length(profile[:bio]))
			aggregate(true, name: name_len, bio: bio_len)
		end
	end


	property "naive queue generation" do
		forall list <- list({term(), term()}) do
			q = :queue.from_list(list)
			:queue.is_queue(q)
		end
	end


	property "queue with let macro" do
		forall q <- queue() do
			:queue.is_queue(q)
		end
	end


	# helpers

	def boolean(_) do
		true
	end

	@doc """
	 The to_range/2 fun places a velue M into given buckek of size N.	
	"""
	def to_range(m, n) do
		base = div(n, m)
		{base * m, (base + 1) * m}
	end


	# generators
	

	# oneof([ListOfGenerators]) will randomly pick one of the generators whithin the
	# list passed to it

	def key(), do: oneof([range(1,10), integer()])
	def val(), do: term()

	@doc """
		the ?LET(InstanceOfType, TypeGenerator, Transform)
		macro to apply a transformation to the generated data itself. The macro takes
		the TypeGenerator and binds it to the InstanceOfType variable. That variable can
		then be used in the Transform expression as if it were fully evaluated. The
		evaluation of the final generator is still deferred until later though, which is
		important because it lets us transform it without preventing it from being
		composable with others generators. In other words, ?LET lets you accumulate
		function calls to run on the generator whenever it will be evaluated.
	"""
	def queue do
		let list <- list({term(), term()}) do
			:queue.from_list(list)
		end
	end


	@doc """
		the ?SUCHTHAT(InstanceOfType, TypeGenerator,
		BooleanExp) macro.
		The macro works in a similar manner as ?LET/3 : the TypeGenerator is bound to
		InstanceOfType , which can then be used in BooleanExp . One distinction is that
		BooleanExp needs to be a boolean expression, returning true or false . If the value
		is true , the data generated is kept and allowed to go through. If the value is
		false , the data is prevented from being passed to the test; instead, PropEr will
		try to generate a new piece of data that hopefully satisfies the filter.
	"""
  def non_empty(list_type) do
		such_that l <- list_type, when: l != [] and l != <<>>
	end

	def non_empty_map(gen) do
		such_that g <- gen, when: g != %{}
	end

	@doc"""
		Using ?LET() lets us transform all of that data, and ?SUCHTHAT() lets us remove
		some of it
	"""
	# let variant
	def even2(), do: let n <- integer(), do: N * 2
	def uneven2(), do: let n <- integer(), do: n * 2 + 1

	# such_that variant
	def even(), do: such_that n <- integer(), when: rem(n, 2) == 0
	def uneven(), do: such_that n <- integer(), when: rem(n, 2) != 0



	# models

end # oef mudule
