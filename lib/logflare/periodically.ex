defmodule Logflare.Periodically do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    schedule_work() # Schedule work to be performed on start
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the desired work here
    # IO.puts "Periodically GenServer Running"
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 60000) # In 60 seconds
  end
end