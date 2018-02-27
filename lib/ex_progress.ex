defmodule ExProgress do
  @moduledoc """
  The top-level module for `ex_progress`, a library for tracking progress across many tasks.

  Simple example with one process:

      {:ok, progress} = ExProgress.start_link(10)

      task =
        Task.async(fn ->
          # do some work...
          ExProgress.complete_work_unit(progress)
          # do more work...
          ExProgress.complete_work_unit(progress)
          # ...
          ExProgress.complete_work_unit(progress)
        end)

      Task.await(task, :infinity)

      ExProgress.fraction_completed(progress) == 1.0 # true

  You can also build trees of processes, which is where it gets interesting:

      {:ok, task1_progress} = ExProgress.start_link(10)
      {:ok, task2_progress} = ExProgress.start_link(10)
      {:ok, overall_progress} =
        ExProgress.start_link(10, fn(progress) ->
          IO.puts "Overall progress: \#{progress}"
        end)

      ExProgress.add_child(overall_progress, task1_progress, 8)
      ExProgress.add_child(overall_progress, task2_progress, 2)

      task1 =
        Task.async(fn ->
          # do some work...
          ExProgress.complete_work_unit(progress)
          # do more work...
          ExProgress.complete_work_unit(progress)
          # ...
          ExProgress.complete_work_unit(progress)
        end)

      task2 =
        Task.async(fn ->
          # do some work...
          ExProgress.complete_work_unit(progress)
          # ...
          ExProgress.complete_work_unit(progress)
        end)

      [task1, task2] |> Enum.each(&Task.await(&1, :infinity))

      ExProgress.fraction_completed(progress) == 1.0 // true

  In the above example, `task1` and `task2` each have 10 work units that they track internally,
  but their relative contributions to the overall progress are different. The calls to `add_child`
  say that `task1` represents eight of the 10 overall work units, while `task2` represents only two.
  This strategy means that child processes don't need to care about their parent; they can focus on
  the task at hand and manage it in a way that makes sense. Similarly, the parent doesn't need to
  care about the child's work and only needs to specify how much weight each child should carry.
  """

  defdelegate start_link(total_work_units, callback_fun \\ fn(_) -> :ok end, opts \\ []), to: ExProgress.Server

  defdelegate complete_work_unit(progress), to: ExProgress.Server

  defdelegate update_completed_work_units(progress, completed_work_units), to: ExProgress.Server

  defdelegate add_child(progress, child, portion_of_parent_work_units), to: ExProgress.Server

  defdelegate completed_work_units(progress), to: ExProgress.Server

  defdelegate fraction_completed(progress), to: ExProgress.Server
end
