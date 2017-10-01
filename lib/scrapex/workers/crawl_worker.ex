defmodule Scrapex.CrawlWorker do
  def perform(module_name, parser_name, data) do
    module = Module.concat([module_name])

    Scrapex.Crawler.Callbacks.trigger(module, :before_parse_start)
    apply(module, String.to_atom(parser_name), [data])
    Scrapex.Crawler.Callbacks.trigger(module, :after_parse_complete)
  end
end
