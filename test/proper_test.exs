defmodule Proper.Test do
    use ExUnit.Case

    test "module" do
        assert is_list(Proper.module(Proper.TestModule))
    end

    test "quickcheck" do
        assert Proper.quickcheck(property)
    end

    test "run" do
        {_, failures} = Proper.run(__MODULE__)
        assert length(failures) == 0
    end

    defp property do
      use Proper.Properties
      forall x in integer, do: is_integer(x)
    end
    
end

defmodule Proper.TestModule do
    use Proper.Properties
    
    property simple_forall do
        forall x in integer, do: is_integer(x)
    end

    property :failing_forall do
        forall x in integer, do: x > 0
    end

    property "let" do
        forall x in (let x = pos_integer, do: -x), do: x < 0
    end

    property "suchthat" do
        forall x in (let x = integer, when: x > 0), do: x > 0
    end

    property "suchthatmaybe" do
        forall x in (let x = pos_integer, strict: false, when: x < 0), do: x > 0
    end

end