defmodule Scrapex.Crawler.Callbacks do
  @callbacks [:before_start, :after_start, :before_pause,
              :after_pause, :before_terminate, :after_terminate,
              :before_resume, :after_resume, :after_complete,
              :before_parse_start, :after_parse_start,
              :after_parse_complete, :before_parse_complete]

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      @defined_callbacks []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def trigger_callback(callback_name) do
        callbacks = Keyword.get(defined_callbacks(), callback_name, [])

        Enum.each(callbacks, fn (fun) ->
          cond do
            is_function(fun) -> fun.()
            is_atom(fun)     -> apply(__MODULE__, fun, [])
            true             -> raise "No allowed"
          end
        end)
      end

      def defined_callbacks, do: @defined_callbacks
    end
  end

  for callback_name <- @callbacks do
    defmacro unquote(callback_name)(fun) do
      add_callback(unquote(callback_name), fun)
    end
  end

  defp add_callback(callback_name, do: block) do
    quote bind_quoted: [callback_name: escape(callback_name), block: escape(block)] do
      callbacks     = Keyword.get(@defined_callbacks, callback_name, [])
      function_name = :"__#{callback_name}_#{length(callbacks)}"

      @defined_callbacks Keyword.put(@defined_callbacks, callback_name, callbacks ++ [function_name])
      def unquote(function_name)(), do: unquote(block)
    end
  end
  defp add_callback(callback_name, fun) do
    quote bind_quoted: [callback_name: callback_name, fun: fun] do
      callbacks = Keyword.get(@defined_callbacks, callback_name, [])
      @defined_callbacks Keyword.put(@defined_callbacks, callback_name, callbacks ++ [fun])
    end
  end

  defp escape(contents) do
    Macro.escape(contents, unquote: true)
  end
end
