defmodule Scrapex.Crawler.Options do
  @available_options [:crawler_name, :queue_name, :queue_size, :max_retries,
                      :interval, :timeout, :worker_module, :start_url, :browser]

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      @default_queue_size    10
      @default_max_retries   10
      @default_interval      10_000
      @default_timeout       10_000
      @default_worker_module Scrapex.Worker

      @default_options [
        crawler_name:  inspect(__MODULE__),
        queue_name:    Macro.underscore(__MODULE__),
        queue_size:    Application.get_env(:scrapex, :queue_size,    @default_queue_size),
        interval:      Application.get_env(:scrapex, :interval,      @default_interval),
        timeout:       Application.get_env(:scrapex, :timeout,       @default_timeout),
        max_retries:   Application.get_env(:scrapex, :max_retries,   @default_max_retries),
        worker_module: Application.get_env(:scrapex, :worker_module, @default_worker_module),
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
      def options,         do: @options
      def default_options, do: @default_options
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
