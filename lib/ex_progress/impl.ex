defmodule ExProgress.Impl do
  @moduledoc """
  """

  def complete_work_unit(count \\ 1, state) do
    state = %{state | completed_work_units: state.completed_work_units + count}
    fraction_completed(state)
  end

  def add_child(child, portion_of_parent_work_units, state) do
    # TODO: Verify that our work units aren't oversubscribed by children
    state = %{state | children: state.children ++ [{child, portion_of_parent_work_units}]}
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

  defp have_children?(state) do
    Enum.any?(state.children)
  end

  defp parent_units_completed_by_children(state) do
    state.children
    |> Enum.reduce(0, fn({child, portion}, total_units_completed) ->
      {:ok, child_units_completed} = ExProgress.completed_work_units(child)
      parent_units_completed_by_child = child_units_completed * (portion / state.total_work_units)
      total_units_completed + parent_units_completed_by_child
    end)
    |> Float.floor()
  end
end
