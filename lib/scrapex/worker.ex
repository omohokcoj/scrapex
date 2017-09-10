defmodule Scrapex.Worker do
  def perform(module_name, parser_name, data) do
    module = Module.concat([module_name])

    module.trigger_callback(:after_parse_start)
    apply(module, String.to_atom(parser_name), [data])
    module.trigger_callback(:before_parse_complete)
  end
end
