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

	# models

end # oef mudule
