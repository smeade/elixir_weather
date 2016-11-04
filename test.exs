defmodule Example do
  def foo(bar, baz \\ nil) do
    IO.inspect [bar, baz]
  end
end
