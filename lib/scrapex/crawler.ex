defmodule Scrapex.Crawler do
  defmacro __using__(opts \\ []) do
    quote do
      use Scrapex.Crawler.Options, unquote(opts)
      use Scrapex.Crawler.Callbacks
      use Scrapex.Crawler.Middleware

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def start,     do: Scrapex.start(__MODULE__)
      def terminate, do: Scrapex.terminate(__MODULE__)
      def pause,     do: Scrapex.pause(__MODULE__)
      def resume,    do: Scrapex.resume(__MODULE__)
      def restart,   do: Scrapex.restart(__MODULE__)

      defp send_data(data),                 do: Scrapex.Crawler.send_data(__MODULE__, data)
      defp yield(parser_name, data \\ %{}), do: Scrapex.Crawler.yield(__MODULE__, parser_name, data)
    end
  end

  def send_data(module, data) do
    Scrapex.Crawler.Callbacks.trigger(module, :before_data_enqueue)

    Exq.enqueue(Exq,
                module.data_queue_name(),
                module.data_worker(),
                [module, data],
                max_retries: module.max_retries())
  end

  def yield(module, parser_name, data \\ %{}) do
    Scrapex.Crawler.Callbacks.trigger(module, :before_parse_enqueue)

    Exq.enqueue(Exq,
                module.crawl_queue_name(),
                module.crawl_worker(),
                [module, parser_name, data],
                max_retries: module.max_retries())
  end
end
