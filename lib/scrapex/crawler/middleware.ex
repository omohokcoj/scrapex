defmodule Scrapex.Crawler.Middleware do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      @defined_middleware []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def process_data(data) do
        Scrapex.Utils.reduce_with(defined_middleware(), data, fn (middleware, acc) ->
          cond do
            is_function(middleware)           -> middleware.(acc)
            Code.ensure_compiled?(middleware) -> apply(middleware, :call, [acc])
            is_atom(middleware)               -> apply(__MODULE__, middleware, [acc])
            true                              -> raise "Not allowed"
          end
        end)
      end

      def defined_middleware, do: @defined_middleware
    end
  end

  defmacro middleware(fun) do
    quote do
      @defined_middleware @defined_middleware ++ [unquote(fun)]
    end
  end
end
