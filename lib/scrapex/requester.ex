defmodule Scrapex.Requester do
  defmacro __using__(opts \\ []) do
    unless Code.ensure_loaded?(HTTPoison) do
      raise "Add {:httpoison, \">= 0.0.0\"} to project deps"
    end

    quote do
      @max_restarts 300
      @max_seconds 30

      @before_compile unquote(__MODULE__)

      before_start do
        __MODULE__.start_link()
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def start_link do
        Task.Supervisor.start_link(restart: :transient, max_restarts: @max_restarts,
                                   max_seconds: @max_seconds, name: __MODULE__)
      end

      defp request(method, url, body \\ "", headers \\ [], options \\ []) do
        Scrapex.Requester.request(__MODULE__, method, url, body, headers, options)
      end

      defp request!(method, url, body \\ "", headers \\ [], options \\ []) do
        Scrapex.Requester.request!(__MODULE__, method, url, body, headers, options)
      end
    end
  end

  def request(supervisor, method, url, body \\ "", headers \\ [], options \\ []) do
    task = Task.Supervisor.async(supervisor, HTTPoison, :request, [method, url, body, headers, options])
    Task.await(task)
  end

  def request!(supervisor, method, url, body \\ "", headers \\ [], options \\ []) do
    task = Task.Supervisor.async(supervisor, HTTPoison, :request!, [method, url, body, headers, options])
    Task.await(task)
  end
end
