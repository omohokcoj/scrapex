defmodule Scrapex.Crawler do
  defmacro __using__(_) do
    quote do
      use Scrapex.Crawler.Helpers
      use Scrapex.Crawler.Callbacks
      use Scrapex.Crawler.Middleware

      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def start do
        trigger_callback(:before_start)
        Exq.subscribe(Exq, queue_name(), queue_size())

        enqueue(:start)
        trigger_callback(:after_start)
      end

      def terminate do
        trigger_callback(:before_terminate)

        trigger_callback(:after_terminate)
      end

      def pause do
        trigger_callback(:before_pause)

        trigger_callback(:after_pause)
      end

      def continue do
        trigger_callback(:before_continue)

        trigger_callback(:after_continue)
      end

      def restart do
        terminate()
        start()
      end

      def yield(parser, data) do
        enqueue(parser, data)
      end

      def enqueue(parser_name, data \\ %{}) do
        trigger_callback(:parse_start)
        Exq.enqueue(Exq, queue_name(), worker_module(), [parser_name, data])
        trigger_callback(:parse_start)
      end
    end
  end
end
