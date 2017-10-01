defmodule Scrapex.Crawler.Middleware do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [middleware: 1, middleware: 2]

      @before_compile unquote(__MODULE__)

      @defined_middleware []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def process_data(data) do
        Scrapex.Crawler.Middleware.apply(__MODULE__, data)
      end

      def defined_middleware, do: @defined_middleware
    end
  end

  defmacro middleware(fun, opts \\ []) do
    quote do
      @defined_middleware @defined_middleware ++ [{unquote(fun), unquote(opts)}]
    end
  end

  def apply(module, data) do
    Enum.reduce_while(module.defined_middleware(), {:ok, data}, fn ({middleware, opts}, {:ok, acc}) ->
      case call(module, middleware, acc, opts) do
        error = {:error, _} -> {:halt, error}
        value = {:ok, _}    -> {:cont, value}
        value               -> {:cont, {:ok, value}}
      end
    end)
  end

  defp call(module, middleware, data, opts) do
    cond do
      is_function(middleware)           -> middleware.(data, opts)
      Code.ensure_compiled?(middleware) -> apply(middleware, :call, [data, opts])
      is_atom(middleware)               -> apply(module, middleware, [data, opts])
      true                              -> raise "Not allowed"
    end
  end
end
