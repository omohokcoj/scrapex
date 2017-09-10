defmodule Scrapex.Crawler.Plugins.PhantomJS do
  defmacro __using__(_) do
    quote do
      use Hound.Helpers

      after_parse_start do
        Hound.start_session(browser: "phantomjs")
      end

      before_parse_complete do
        Hound.end_session(self())
      end
    end
  end
end
