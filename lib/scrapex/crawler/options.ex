defmodule Scrapex.Crawler.Options do
  @available_options [:crawler_name, :queue_name, :queue_size, :max_retries,
                      :interval, :timeout, :worker_module, :start_url]

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      @default_queue_size  10
      @default_max_retries 10
      @default_interval    10_000
      @default_timeout     10_000

      @default_options [
        crawler_name:  inspect(__MODULE__),
        queue_name:    Macro.underscore(__MODULE__),
        queue_size:    Application.get_env(:scrapex, :queue_size,    @default_queue_size),
        interval:      Application.get_env(:scrapex, :interval,      @default_interval),
        timeout:       Application.get_env(:scrapex, :timeout,       @default_timeout),
        max_retries:   Application.get_env(:scrapex, :max_retries,   @default_max_retries),
        worker_module: Application.get_env(:scrapex, :worker_module, default_worker_module()),
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

  defmacro default_worker_module do
    quote do
      module_name = Module.concat([__MODULE__, Worker])

      unless Code.ensure_loaded?(module_name) do
        define_worker_module(module_name)
      end

      module_name
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

  def define_worker_module(module_name) do
    defmodule module_name do
      def perform(parser_name, data) do
        crawler_module = __MODULE__ |> Module.split |> Enum.drop(-1) |> Module.concat

        apply(crawler_module, String.to_atom(parser_name), [data])
      end
    end
  end
end
