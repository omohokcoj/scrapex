defmodule Scrapex do
  def start(module) do
    Scrapex.Crawler.Callbacks.trigger(module, :before_start)

    Exq.subscribe(Exq, module.crawl_queue_name(), module.crawl_queue_size())
    Exq.subscribe(Exq, module.data_queue_name(), module.data_queue_size())

    Scrapex.Crawler.yield(module, module.start_function())

    Scrapex.Crawler.Callbacks.trigger(module, :after_start)
  end

  def terminate(module) do
    Scrapex.Crawler.Callbacks.trigger(module, :before_terminate)

    Exq.Api.remove_queue(Exq.Api, module.crawl_queue_name())
    Exq.Api.remove_queue(Exq.Api, module.data_queue_name())

    Scrapex.Crawler.Callbacks.trigger(module, :after_terminate)
  end

  def pause(module) do
    Scrapex.Crawler.Callbacks.trigger(module, :before_pause)

    Exq.unsubscribe(Exq, module.crawl_queue_name())
    Exq.unsubscribe(Exq, module.data_queue_name())

    Scrapex.Crawler.Callbacks.trigger(module, :after_pause)
  end

  def resume(module) do
    Scrapex.Crawler.Callbacks.trigger(module, :before_resume)

    Exq.subscribe(Exq, module.crawl_queue_name(), module.crawl_queue_size())
    Exq.subscribe(Exq, module.data_queue_name(), module.data_queue_size())

    Scrapex.Crawler.Callbacks.trigger(module, :after_resume)
  end

  def restart(module) do
    terminate(module)
    start(module)
  end
end
