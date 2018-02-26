defmodule ExProgress do
  @moduledoc """
  Documentation for ExProgress.
  """

  defdelegate start_link(total_work_units), to: ExProgress.Server

  defdelegate start_link(total_work_units, children, opts \\ []), to: ExProgress.Server

  defdelegate complete_work_unit(progress), to: ExProgress.Server

  defdelegate update_completed_work_units(progress, completed_work_units), to: ExProgress.Server

  defdelegate add_child(progress, child, portion_of_parent_work_units), to: ExProgress.Server

  defdelegate completed_work_units(progress), to: ExProgress.Server

  defdelegate fraction_completed(progress), to: ExProgress.Server
end
