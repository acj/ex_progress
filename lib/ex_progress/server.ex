defmodule ExProgress.Server do
  @moduledoc false

  alias ExProgress.Impl
  use GenServer

  def start_link(total_work_units) do
    start_link(total_work_units, [])
  end

  def start_link(total_work_units, children, opts \\ []) do
    GenServer.start_link(__MODULE__, [total_work_units, children], opts)
  end

  def init([total_work_units, children]) do
    state = %{
      total_work_units: total_work_units,
      completed_work_units: 0,
      children: children,
    }

    {:ok, state}
  end

  # Delegated functions

  def complete_work_unit(progress, count \\ 1) do
    GenServer.call(progress, {:complete_work_unit, count})
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

  # GenServer

  def handle_call({:complete_work_unit, count}, _from, state) do
    {response, state} = Impl.complete_work_unit(count, state)
    {:reply, response, state}
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
end
