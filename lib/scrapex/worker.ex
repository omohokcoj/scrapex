defmodule Scrapex.Worker do
  use Hound.Helpers
  @start_url "http://rozklad.nung.edu.ua/faculties.php"

  def perform do
    Hound.start_session()

    navigate_to("http://example.com/guestbook.html")

    IO.inspect Exq.worker_job()
    IO.inspect page_title()

    Hound.end_session(self())
  end
end
