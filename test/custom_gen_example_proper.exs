defmodule CustomGenExampleProper do
	use ExUnit.Case
	use PropCheck

	# property

	property "always works" do
		forall type <- term() do
			boolean(type)
		end
	end


	property "find all keys in a map enven when dupes are used" do
		forall kv <- list({key(), val()}) do
			m = Map.new(kv)
			for {k,_v} <- kv, do: Map.fetch!(m, k)
			true
		end
	end


	# make verbose for metrics
	property "collect 1", [:verbose] do
		forall bin <- binary() do
			#          test           metric
			collect(is_binary(bin), byte_size(bin))
		end
	end	


	# helpers

	def boolean(_) do
		true
	end

	# generators
	
	def key(), do: integer()
	def val(), do: term()

	# models

end # oef mudule
