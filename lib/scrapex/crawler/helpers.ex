defmodule Scrapex.Crawler.Helpers do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      @crawler_name  inspect(__MODULE__)
      @queue_name    Macro.underscore(__MODULE__)
      @queue_size    10
      @worker_module define_worker_module()
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def crawler_name,  do: @crawler_name
      def queue_name,    do: @queue_name
      def queue_size,    do: @queue_size
      def start_url,     do: @start_url
      def worker_module, do: @worker_module
    end
  end

  defmacro crawler_name(name) when is_bitstring(name) do
    quote do
      Module.put_attribute(__MODULE__, :crawler_name, unquote(name))
    end
  end

  defmacro queue_name(name) when is_bitstring(name) do
    quote do
      Module.put_attribute(__MODULE__, :queue_name, unquote(name))
    end
  end

  defmacro queue_size(size) when is_integer(size) do
    quote do
      Module.put_attribute(__MODULE__, :queue_size, unquote(size))
    end
  end

  defmacro worker_module(module) when is_atom(module) do
    quote do
      Module.put_attribute(__MODULE__, :worker_module, unquote(module))
    end
  end

  defmacro start_url(url) when is_bitstring(url) do
    quote do
      Module.put_attribute(__MODULE__, :start_url, unquote(url))
    end
  end


  defmacro define_worker_module do
    quote do
      module_name = Module.concat([__MODULE__, Worker])

      defmodule module_name do
        def perform(parser_name, data) do
          crawler_module = __MODULE__ |> Module.split |> Enum.drop(-1) |> Module.concat

          apply(crawler_module, String.to_atom(parser_name), [data])
        end
      end

      module_name
    end
  end
end
