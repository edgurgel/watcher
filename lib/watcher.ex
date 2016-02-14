defmodule Watcher do
  @moduledoc """
  Watcher for a GenEvent handler

  This GenServer will monitor the GenEvent manager and the handler so it stops
  if any of them stop.

  This effectively is a simple way of using a handler as a process that can be spawned
  and/or added to a supervision tree.

  This module is inspered by the Logger.Watcher
  """

  require Logger
  use GenServer
  @name Logger.Watcher

  @doc """
  Starts and links the watcher.
  """
  def start_link(manager, handler, args, opts \\ []) do
    GenServer.start_link(__MODULE__, [manager, handler, args], opts)
  end

  @doc """
  Starts the watcher.
  """
  def start(manager, handler, args, opts \\ []) do
    GenServer.start(__MODULE__, [manager, handler, args], opts)
  end

  @doc false
  def init([manager, handler, args]) do
    ref = Process.monitor(manager)
    case GenEvent.add_mon_handler(manager, handler, args) do
      :ok -> { :ok, { manager, handler, ref } }
      { :error, reason }  -> { :stop, reason }
    end
  end

  @doc false
  def handle_info({ :gen_event_EXIT, handler, reason }, {_, handler, _} = state)
      when reason in [:normal, :shutdown] do
    { :stop, reason, state }
  end

  def handle_info({ :gen_event_EXIT, handler, reason }, {manager, handler, _} = state) do
    _ = Logger.error "GenEvent handler #{inspect handler} installed at #{inspect manager}\n" <>
                 "** (exit) #{format_exit(reason)}"
    { :stop, reason, state }
  end

  def handle_info({ :DOWN, ref, _, _, reason }, {manager, handler, ref} = state) do
    _ = Logger.error "GenEvent handler #{inspect handler} installed at #{inspect manager}\n" <>
                 "** (exit) #{format_exit(reason)}"
    { :stop, reason, state }
  end

  def handle_info(_msg, state), do: { :noreply, state }

  defp format_exit({ :EXIT, reason }), do: Exception.format_exit(reason)
  defp format_exit(reason), do: Exception.format_exit(reason)
end
