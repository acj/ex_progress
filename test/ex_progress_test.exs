defmodule ExProgressTest do
  use ExUnit.Case
  doctest ExProgress

  describe "complete_work_unit/1" do
    test "completing the only work unit yields 100% completed" do
      {:ok, progress} = ExProgress.start_link(1)

      ExProgress.complete_work_unit(progress)

      assert ExProgress.fraction_completed(progress) == {:ok, 1.0}
    end

    test "completing a work unit yields one completed work unit" do
      {:ok, progress} = ExProgress.start_link(1)

      ExProgress.complete_work_unit(progress)

      assert ExProgress.completed_work_units(progress) == {:ok, 1}
    end

    test "updating the completed work unit count invokes the callback" do
      pid = self()
      {:ok, progress} = ExProgress.start_link(1, fn(frac_completed) -> send(pid, {:progress, frac_completed}) end)

      ExProgress.update_completed_work_units(progress, 1)

      assert ExProgress.fraction_completed(progress) == {:ok, 1.0}
      assert_receive {:progress, 1.0}

    end

    test "parent completing a work unit invokes the callback" do
      pid = self()
      {:ok, progress} = ExProgress.start_link(1, fn(frac_completed) -> send(pid, {:progress, frac_completed}) end)

      ExProgress.complete_work_unit(progress)

      assert ExProgress.fraction_completed(progress) == {:ok, 1.0}
      assert_receive {:progress, 1.0}
    end

    test "a child completing a work unit invokes the callback" do
      pid = self()
      callback_fun = fn(frac_completed) -> send(pid, {:progress, frac_completed}) end
      {:ok, parent} = ExProgress.start_link(1, callback_fun)
      {:ok, child} = ExProgress.start_link(1)

      :ok = ExProgress.add_child(parent, child, 1)

      ExProgress.complete_work_unit(child)

      assert ExProgress.fraction_completed(parent) == {:ok, 1.0}
      assert_receive {:progress, 1.0}
    end

    test "a grandchild completing a work unit invokes the callback" do
      pid = self()
      callback_fun = fn(frac_completed) -> send(pid, {:progress, frac_completed}) end
      {:ok, grandparent} = ExProgress.start_link(1, callback_fun)
      {:ok, parent} = ExProgress.start_link(1)
      {:ok, child} = ExProgress.start_link(1)

      :ok = ExProgress.add_child(grandparent, parent, 1)
      :ok = ExProgress.add_child(parent, child, 1)

      ExProgress.complete_work_unit(child)

      assert ExProgress.fraction_completed(parent) == {:ok, 1.0}
      assert_receive {:progress, 1.0}
    end

    test "a child updating its completed work unit count invokes the callback" do
      pid = self()
      callback_fun = fn(frac_completed) -> send(pid, {:progress, frac_completed}) end
      {:ok, parent} = ExProgress.start_link(1, callback_fun)
      {:ok, child} = ExProgress.start_link(1)

      :ok = ExProgress.add_child(parent, child, 1)

      ExProgress.update_completed_work_units(child, 1)

      assert ExProgress.fraction_completed(parent) == {:ok, 1.0}
      assert_receive {:progress, 1.0}
    end
  end


  describe "add_child/2" do
    test "child not having completed any work means that the parent hasn't either" do
      {:ok, parent} = ExProgress.start_link(1)
      {:ok, child} = ExProgress.start_link(1)

      :ok = ExProgress.add_child(parent, child, 1)

      assert ExProgress.fraction_completed(child) == {:ok, 0.0}
      assert ExProgress.fraction_completed(parent) == {:ok, 0.0}
    end

    test "lone child completing its work means that the parent has completed its work" do
      {:ok, parent} = ExProgress.start_link(1)
      {:ok, child} = ExProgress.start_link(1)

      :ok = ExProgress.add_child(parent, child, 1)

      :ok = ExProgress.complete_work_unit(child)

      assert ExProgress.fraction_completed(child) == {:ok, 1.0}
      assert ExProgress.fraction_completed(parent) == {:ok, 1.0}
    end

    test "two children completing 50% each means that the parent has completed 50%" do
      {:ok, parent} = ExProgress.start_link(4)
      {:ok, child1} = ExProgress.start_link(2)
      {:ok, child2} = ExProgress.start_link(2)

      :ok = ExProgress.add_child(parent, child1, 2)
      :ok = ExProgress.add_child(parent, child2, 2)

      :ok = ExProgress.complete_work_unit(child1)
      :ok = ExProgress.complete_work_unit(child2)

      assert ExProgress.fraction_completed(child1) == {:ok, 0.5}
      assert ExProgress.fraction_completed(child2) == {:ok, 0.5}
      assert ExProgress.fraction_completed(parent) == {:ok, 0.5}
    end
  end

  describe "stress tests" do
    test "correctness with large number of children" do
      pid = self()
      how_many = 250
      callback_fun = fn(frac_completed) -> send(pid, {:progress, frac_completed}) end
      {:ok, parent} = ExProgress.start_link(how_many, callback_fun)

      children = Enum.map(0..(how_many-1), fn(_) ->
        {:ok, child} = ExProgress.start_link(1000)
        :ok = ExProgress.add_child(parent, child, 1)
        child
      end)

      Enum.each(0..(how_many-1), fn(i) ->
        ExProgress.update_completed_work_units(Enum.at(children, i), 500)
      end)

      Enum.each(0..(how_many-1), fn(i) ->
        ExProgress.update_completed_work_units(Enum.at(children, i), 1000)
      end)

      assert ExProgress.fraction_completed(parent) == {:ok, 1.0}
      assert_receive {:progress, 1.0}
    end
  end
end
