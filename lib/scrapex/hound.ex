defmodule Scrapex.Hound do
  defmacro __using__(opts \\ []) do
    unless Code.ensure_loaded?(Hound) do
      raise "Please add {:hound, \">= 0.0.0\"} to project deps"
    end

    quote do
      use Hound.Helpers

      before_parse_start do
        Hound.start_session(unquote(opts))
      end

      after_parse_complete do
        Hound.end_session(self())
      end
    end
  end
end
