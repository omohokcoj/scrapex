defmodule Scrapex.Crawler do
  defmacro __using__(opts \\ []) do
    quote do
      use Scrapex.Crawler.Options, unquote(opts)
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

      def resume do
        trigger_callback(:before_resume)

        trigger_callback(:after_resume)
      end

      def restart do
        terminate()
        start()
      end

      def send_data(data) do
        enqueue(:process_data, data)
      end

      def yield(parser_name, data) do
        enqueue(parser_name, data)
      end

      def enqueue(parser_name, data \\ %{}) do
        trigger_callback(:before_parse_start)
        Exq.enqueue(Exq, queue_name(), worker_module(), [__MODULE__, parser_name, data])
        trigger_callback(:after_parse_complete)
      end
    end
  end
end
