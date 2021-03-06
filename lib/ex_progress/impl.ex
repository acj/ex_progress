defmodule ExProgress.Impl do
  @moduledoc false

  def complete_work_unit(count \\ 1, state) do
    state = %{state | completed_work_units: state.completed_work_units + count}
    notify_callback(state)
    fraction_completed(state)
  end

  def update_completed_work_units(count, state) do
    state = %{state | completed_work_units: count}
    notify_callback(state)
    fraction_completed(state)
  end

  def add_child(child, portion_of_parent_work_units, state) do
    # TODO: Verify that our work units aren't oversubscribed by children
    state = %{state | children: state.children ++ [{child, portion_of_parent_work_units}]}

    parent = self()
    :ok = ExProgress.Server.update_callback(child, fn(_) ->
      ExProgress.complete_work_unit(parent)
    end)
    {:ok, state}
  end

  def completed_work_units(state) do
    {{:ok, state.completed_work_units}, state}
  end

  def fraction_completed(state) do
    val =
      if have_children?(state) do
        parent_units_completed_by_children(state) / state.total_work_units
      else
        state.completed_work_units / state.total_work_units
      end

    {{:ok, val}, state}
  end

  def update_callback(state, new_callback_fun) do
    state = %{state | callback_fun: new_callback_fun}
    {:ok, state}
  end

  defp notify_callback(state) do
    if fun = state.callback_fun do
      {{:ok, progress}, _state} = fraction_completed(state)
      fun.(progress)
    end
  end

  defp have_children?(state) do
    Enum.any?(state.children)
  end

  defp parent_units_completed_by_children(state) do
    state.children
    |> Enum.reduce(0, fn({child, childs_portion_of_parent_work_units}, total_units_completed) ->
      {:ok, child_progress} = ExProgress.fraction_completed(child)
      parent_units_completed_by_child = child_progress * childs_portion_of_parent_work_units
      total_units_completed + parent_units_completed_by_child
    end)
    |> Float.floor()
  end
end
