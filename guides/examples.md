# Examples

## HTTP crawler

```elixir
defmodule PragmaticBookshelfCrawler do
  use Scrapex.Crawler
  use Scrapex.Requester

  import Meeseeks
  import Meeseeks.XPath

  start_url "https://pragprog.com/titles/category/gaming?f[sort_by]=pubdate&f[category]=all&f[skill_level]=All&f[title_contains]="

  middleware :inspect

  max_retries 0
  crawl_queue_size 1

  def start(_) do
    page = request!(:get, start_url()).body

    categories = all(page, xpath("//*[@id='title_filter_params_category']/option"))

    Enum.each(categories, fn (elem) ->
      yield(:parse_category, %{category_name: text(elem),
                               category_value: attr(elem, "value")})
    end)
  end

  def parse_category(data) do
    page = request!(:get, "https://pragprog.com/titles/category/gaming?f[sort_by]=pubdate&f[category]=#{data["category_value"]}&f[skill_level]=All&f[title_contains]=").body


    books = all(page, xpath("//*[@id='filter-o-matic']/div/ul/li[not(contains(@style, 'display: none'))]/a"))

    Enum.each(books, fn (elem) ->
      yield(:parse_book, Map.merge(data, %{book_url: attr(elem, "href")}))
    end)
  end

  def parse_book(data) do
    page = request!(:get, data["book_url"]).body

    send_data(%{
      category:    data["category_name"],
      url:         data["book_url"],
      title:       text(one(page, xpath("//h1/text()"))),
      subtitle:    text(one(page, xpath("//h2/text()"))),
      author:      text(one(page, xpath("//span[@itemprop='author']"))),
      description: text(one(page, xpath("//article[@itemprop='description']/p"))),
      image_url:   attr(one(page, xpath("//a[img[@itemprop='image']]")), "href")
    })
  end

  def inspect(data, opts \\ []) do
    IO.inspect data
  end
end
```

## PhantomJS crawler

```elixir
defmodule PragmaticBookshelfCrawler do
  use Scrapex.Crawler
  use Scrapex.Hound, browser: "phantomjs"

  start_url "https://pragprog.com/titles/category/gaming?f[sort_by]=pubdate&f[category]=all&f[skill_level]=All&f[title_contains]="

  middleware :inspect

  before_parse_start do
    delete_cookies()
  end

  crawl_queue_size 4

  def start(_) do
    navigate_to(start_url())

    categories = find_all_elements(:xpath, "//*[@id='title_filter_params_category']/option")

    Enum.each(categories, fn (elem) ->
      yield(:parse_category, %{category_value: attribute_value(elem, "value"),
                               category_name: inner_text(elem)})
    end)
  end

  def parse_category(data) do
    navigate_to("https://pragprog.com/titles/category/gaming?f[sort_by]=pubdate&f[category]=#{data["category_value"]}&f[skill_level]=All&f[title_contains]=")

    :timer.sleep(2000)

    books = find_all_elements(:xpath, "//*[@id='filter-o-matic']/div/ul/li[not(contains(@style, 'display: none'))]/a")

    Enum.each(books, fn (elem) ->
      yield(:parse_book, Map.merge(data, %{book_url: attribute_value(elem, "href")}))
    end)
  end

  def parse_book(data) do
    navigate_to(data["book_url"])

    send_data(%{
      category:    data["category_name"],
      url:         data["book_url"],
      title:       inner_text({:tag, "h1"}),
      subtitle:    inner_text({:tag, "h2"}),
      author:      inner_text({:xpath, "//span[@itemprop='author']"}),
      description: inner_text({:xpath, "//article[@itemprop='description']/p"}),
      image_url:   attribute_value({:xpath, "//a[img[@itemprop='image']]"}, "href")
    })
  end

  def inspect(data, opts \\ []) do
    IO.inspect data
  end
end
```
