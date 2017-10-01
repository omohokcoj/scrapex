defmodule Scrapex.Crawler.Options do
  @available_options [
    :crawl_queue_name,
    :crawl_queue_size,
    :crawl_worker,
    :crawler_name,
    :data_queue_name,
    :data_queue_size,
    :data_worker,
    :max_retries,
    :start_function,
    :start_url
  ]

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      @default_crawl_queue_size 10
      @default_data_queue_size  100
      @default_max_retries      3
      @default_crawl_worker     Scrapex.CrawlWorker
      @default_data_worker      Scrapex.DataWorker
      @start_function           :start

      @default_options [
        crawler_name:     inspect(__MODULE__),
        crawl_queue_name: Macro.underscore(__MODULE__),
        data_queue_name:  Macro.underscore(__MODULE__),
        max_retries:      Application.get_env(:scrapex, :max_retries,         @default_max_retries),
        crawl_queue_size: Application.get_env(:scrapex, :crawl_queue_size,    @default_crawl_queue_size),
        crawl_worker:     Application.get_env(:scrapex, :crawl_worker_module, @default_crawl_worker),
        data_queue_size:  Application.get_env(:scrapex, :data_queue_size,     @default_data_queue_size),
        data_worker:      Application.get_env(:scrapex, :data_worker_module,  @default_data_worker),
        start_function:   Application.get_env(:scrapex, :start_function,      @start_function)
      ]

      @options Keyword.merge(@default_options, unquote(opts))
    end
  end

  defmacro __before_compile__(_) do
    [compile_options(), compile_helpers()]
  end

  for option_name <- @available_options do
    defmacro unquote(option_name)(value) do
      option = [{unquote(option_name), value}]

      quote do
        options = Keyword.merge(@options, unquote(option))
        Module.put_attribute(__MODULE__, :options, options)
      end
    end
  end

  defp compile_options do
    quote do
      def options, do: @options
    end
  end

  defp compile_helpers do
    Enum.map(@available_options, fn (option_name) ->
      quote do
        def unquote(option_name)(), do: options()[unquote(option_name)]
      end
    end)
  end
end
