# Watcher

[![Build Status](https://travis-ci.org/edgurgel/watcher.svg?branch=master)](https://travis-ci.org/edgurgel/watcher) [![Hex.pm](https://img.shields.io/hexpm/v/watcher.svg?style=flat-square)](https://hex.pm/packages/watcher)

Watcher will monitor a GenEvent manager and a handler. If any of them die the watcher will stop.

If added on a supervision tree the watcher will restart, add the handler and keep processing events.

## Installation

First, add Watcher to your mix.exs dependencies:

```elixir
def deps do
  [{:watcher, "~> 1.0.0"}]
end
```

and run `mix deps.get`. Now, list the `:watcher` application as your application dependency:

```elixir
def application do
  [applications: [:watcher]]
end
```

## Basic Usage

Instead of adding a handler with `GenEvent.add_handler(manager, handler, args)` or `GenEvent.add_mon_handler(manager, handler, args)` just use

```elixir
Watcher.start_link(manager, handler, args)
```

Or add to a supervision tree

```elixir
worker(Watcher, [manager, handler, args])
```

Watcher will also accept the same options that a GenServer accepts (`name`, `debug`, etc)
