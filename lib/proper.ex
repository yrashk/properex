defmodule Proper.Properties do
    defmacro __using__(_) do
        quote do
            import Proper
            import Proper.Properties
            import :proper_types, except: [lazy: 1, to_binary: 1]
        end
    end
    
    defmacro property(name, opts) do
        case name do
            {name, _, _} ->
                prop_name = list_to_atom('prop_' ++ List.Chars.to_char_list(name))
            name when is_atom(name) or is_binary(name) or is_list(name) ->
                prop_name = list_to_atom('prop_' ++ List.Chars.to_char_list(name))
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

    defmacro forall({:"in", _, [x, rawtype]}, [{:"do", prop}]) do
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

    defmacro let({:"=", _, [x, rawtype]},[{:when, condition}]) do
        quote do
            :proper_types.add_constraint(unquote(rawtype),fn(unquote(x)) -> unquote(condition) end,true)
        end
    end

    defmacro let({:"=", _, [x, rawtype]},[{:when_maybe, condition}]) do
        quote do
            :proper_types.add_constraint(unquote(rawtype),fn(unquote(x)) -> unquote(condition) end,true)
        end
    end

    defmacro shrink(gen, alt_gens) do
        quote do
            :proper_types.shrinkwith(Proper.delay(unquote(gen)), Proper.delay(unquote(alt_gens)))
        end
    end

    defmacro letshrink({:"=", _, [x, rawtype]},[{:do, gen}]) do
        quote do
            :proper_types.bind(unquote(rawtype), fn(unquote(x)) -> unquote(gen) end, true)
        end
    end

    # Delegates

    defdelegate [quickcheck:1, quickcheck:2, counterexample:1, counterexample:2,
                 check:2, check:3, module:1, module:2, check_spec:1, check_spec:2,
                 check_specs:1, checkl_specs: 2,
                 numtests:2, fails:1, on_output:2, conjunction:1,
                 collect:2, colelct:3, aggregate:2, aggregate:3, classify:3, measure:3,
                 with_title:1, equals:2], to: :proper

end