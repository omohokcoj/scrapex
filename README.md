# Scrapex

Fast and robust web crawling tool in Elixir.
Powered by job processing library - [Exq](https://github.com/akira/exq)

## Features
- Minimal and easy to use DSL - [examples](https://github.com/omohokcoj/scrapex/blob/master/guides/EXAMPLES.md).
- PhantomJS rendering via [Hound](https://github.com/HashNuke/hound).
- Queue, concurrent processing, retries, fault-tolerance - all thanks to Exq and Elixir/OTP.

## Installation

```elixir
def deps do
  [
    {:scrapex, "~> 0.1.0"}
  ]
end
```
