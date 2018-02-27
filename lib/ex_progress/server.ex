defmodule ExProgress.Server do
  @moduledoc false

  alias ExProgress.Impl
  use GenServer

  def start_link(total_work_units, callback_fun \\ fn(_) -> :ok end, opts \\ []) do
    GenServer.start_link(__MODULE__, [total_work_units, callback_fun], opts)
  end

  def init([total_work_units, callback_fun]) do
    state = %{
      total_work_units: total_work_units,
      completed_work_units: 0,
      children: [],
      callback_fun: callback_fun
    }

    {:ok, state}
  end

  # Delegated functions

  def complete_work_unit(progress, count \\ 1) do
    GenServer.cast(progress, {:complete_work_unit, count})
  end

  def update_completed_work_units(progress, count) do
    GenServer.cast(progress, {:update_completed_work_units, count})
  end

  def add_child(progress, child, portion_of_parent_work_units) do
    GenServer.call(progress, {:add_child, child, portion_of_parent_work_units})
  end

  def fraction_completed(progress) do
    GenServer.call(progress, {:fraction_completed})
  end

  def completed_work_units(progress) do
    GenServer.call(progress, {:completed_work_units})
  end

  def update_callback(progress, new_callback_fun) do
    GenServer.call(progress, {:update_callback, new_callback_fun})
  end

  # GenServer

  def handle_cast({:complete_work_unit, count}, state) do
    {_response, state} = Impl.complete_work_unit(count, state)
    {:noreply, state}
  end

  def handle_cast({:update_completed_work_units, count}, state) do
    {_response, state} = Impl.update_completed_work_units(count, state)
    {:noreply, state}
  end

  def handle_call({:add_child, child, portion_of_parent_work_units}, _from, state) do
    {response, state} = Impl.add_child(child, portion_of_parent_work_units, state)
    {:reply, response, state}
  end

  #  def handle_call({:remove_child, child}, _from, state) do
  #  end

  def handle_call({:completed_work_units}, _from, state) do
    {response, state} = Impl.completed_work_units(state)
    {:reply, response, state}
  end

  def handle_call({:fraction_completed}, _from, state) do
    {response, state} = Impl.fraction_completed(state)
    {:reply, response, state}
  end

  def handle_call({:update_callback, new_callback_fun}, _from, state) do
    {response, state} = Impl.update_callback(state, new_callback_fun)
    {:reply, response, state}
  end
end
