defmodule Proper.Properties do
    defmacro __using__(_) do
        quote do
            import Proper
            import Proper.Properties
            import :proper_types, except: [lazy: 1, to_binary: 1, function: 2]
        end
    end
    
    defmacro property(name, opts) do
        case name do
            {name, _, _} ->
                prop_name = :"prop_#{name}"
            name when is_atom(name) or is_binary(name) or is_list(name) ->
                prop_name = :"prop_#{name}"
        end
        quote do
            def unquote(prop_name).(), unquote(opts)
        end
    end
end

defmodule Proper do
    #
    # Test generation macros
    #

    defmacro forall({:in, _, [x, rawtype]}, [do: prop]) do
        quote do
            :proper.forall(unquote(rawtype), fn(unquote(x)) -> unquote(prop) end)
        end
    end
    
    defmacro implies(pre, prop) do
        quote do
            :proper.implies(unquote(pre), Proper.delay(unquote(prop)))
        end
    end

    defmacro whenfail(action, prop) do
        quote do
            :proper.whenfail(Proper.delay(unquote(action)), Proper.delay(unquote(prop)))
        end
    end

    defmacro trapexit(prop) do
        quote do
            :proper.trapexit(Proper.delay(unquote(prop)))
        end
    end

    defmacro timeout(limit, prop) do
        quote do
            :proper.timeout(unquote(limit), Proper.delay(unquote(prop)))
        end
    end


    # Generator macros
    defmacro force(x) do
        quote do
            unquote(x).()
        end
    end

    defmacro delay(x) do
        quote do
            fn() -> unquote(x) end
        end
    end

    defmacro lazy(x) do
        quote do
            :proper_types.lazy(Proper.delay(unquote(x)))
        end
    end

    defmacro sized(size_arg, gen) do
        quote do
            :proper_types.sized(fn(unquote(size_arg)) -> unquote(gen) end)
        end
    end

    defmacro let({:"=", _, [x, rawtype]},[{:do, gen}]) do
        quote do
            :proper_types.bind(unquote(rawtype), fn(unquote(x)) -> unquote(gen) end, false)
        end
    end

    defmacro let({:"=", _, [x, rawtype]}, opts) do
        unless opts[:when], do: throw(:badarg)
        condition = opts[:when]
        strict = Keyword.get(opts, :strict, true)
        quote do
            :proper_types.add_constraint(unquote(rawtype),fn(unquote(x)) -> unquote(condition) end, unquote(strict))
        end
    end

    defmacro shrink(gen, alt_gens) do
        quote do
            :proper_types.shrinkwith(Proper.delay(unquote(gen)), Proper.delay(unquote(alt_gens)))
        end
    end

    defmacro letshrink({:=, _, [x, rawtype]},[do: gen]) do
        quote do
            :proper_types.bind(unquote(rawtype), fn(unquote(x)) -> unquote(gen) end, true)
        end
    end

    # Delegates

    defdelegate [quickcheck(outer_test), quickcheck(outer_test, user_opts),
                 counterexample(outer_test), counterexample(outer_test, user_opts),
                 check(outer_test, cexm), check(outer_test, cexm, user_opts),
                 module(mod), module(mod, user_opts), check_spec(mfa), check_spec(mfa, user_opts),
                 check_specs(mod), check_specs(mod, user_opts),
                 numtests(n, test), fails(test), on_output(print, test), conjunction(sub_props),
                 collect(category, test), collect(printer, category, test),
                 aggregate(sample, test), aggregate(printer, sample, test),
                 classify(count, sample, test), measure(title, sample, test),
                 with_title(title), equals(a,b)], to: :proper

end
