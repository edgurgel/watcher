defmodule WatcherTest do
  use ExUnit.Case
  doctest Watcher
  import Watcher

  @manager WatcherTest.Manager
  @handler WatcherTest.Handler

  defmodule Handler do
    use GenEvent

    # def handle_event(:stop, state) do
      # Process.exit(self, :normal)
    # end
  end

  test "init adds monitored handler" do
    { :ok, manager } = GenEvent.start_link

    assert { :ok, _ref } = init([manager, @handler, []])
    assert { :monitors, process: manager } = Process.info(self, :monitors)
    assert GenEvent.which_handlers(manager) == [@handler]
  end

  test "handle_info :gen_event_EXIT stops watcher" do
    state = { @manager, @handler, :ref }
    assert handle_info({ :gen_event_EXIT, @handler, :normal }, state) == { :stop, :normal, state }
    assert handle_info({ :gen_event_EXIT, @handler, :shutdown }, state) == { :stop, :shutdown, state }
    assert handle_info({ :gen_event_EXIT, @handler, :crash }, state) == { :stop, :crash, state }
    assert handle_info({ :gen_event_EXIT, :other_handler, :crash }, state) == { :noreply, state }
  end

  test "handle_info :gen_event_EXIT from unknown handler does not stop watcher" do
    state = { @manager, @handler, :ref }
    assert handle_info({ :gen_event_EXIT, :other_handler, :crash }, state) == { :noreply, state }
  end

  test "handle_info DOWN from manager stops watcher" do
    state = { @manager, @handler, :ref }
    assert handle_info({ :DOWN, :ref, :process, :pid, :reason}, state) == { :stop, :reason, state }
  end

  test "handle_info DOWN from other monitor ref does not stops watcher" do
    state = { @manager, @handler, :ref }
    assert handle_info({ :DOWN, :other_ref, :process, :pid, :reason}, state) == { :noreply, state }
  end

  test "removing handler stops watcher" do
    Process.flag(:trap_exit, true)
    { :ok, manager } = GenEvent.start_link
    { :ok, watcher } = Watcher.start_link(manager, Handler, [1, 2, 3])

    assert GenEvent.remove_handler(manager, Handler, [1, 2, 3]) == :ok
    assert_receive {:EXIT, ^watcher, :normal}
  end

  test "stopping manager stops watcher" do
    Process.flag(:trap_exit, true)
    { :ok, manager } = GenEvent.start_link
    { :ok, watcher } = Watcher.start_link(manager, Handler, [1, 2, 3])

    reason = :reason
    Process.exit(manager, reason)
    assert_receive { :EXIT, ^manager, ^reason }
    assert_receive { :EXIT, ^watcher, ^reason }
  end
end
