defmodule Scrapex.DataWorker do
  def perform(module_name, data) do
    module = Module.concat([module_name])

    Scrapex.Crawler.Callbacks.trigger(module, :before_data_process_start)
    apply(module, :process_data, [data])
    Scrapex.Crawler.Callbacks.trigger(module, :after_data_processed)
  end
end
