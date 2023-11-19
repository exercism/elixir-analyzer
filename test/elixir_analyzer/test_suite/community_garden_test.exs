defmodule ElixirAnalyzer.ExerciseTest.CommunityGardenTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.CommunityGarden

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "example solution",
    comments: [Constants.solution_same_as_exemplar()] do
    ~S"""
      defmodule Plot do
        @enforce_keys [:plot_id, :registered_to]
        defstruct [:plot_id, :registered_to]
      end

      defmodule CommunityGarden do
        def start(opts \\ []) do
          Agent.start(fn -> %{registry: %{}, next_id: 1} end, opts)
        end

        def list_registrations(pid) do
          Agent.get(pid, fn state ->
            Map.values(state.registry)
          end)
        end

        def register(pid, register_to) do
          Agent.get_and_update(pid, fn %{registry: registry, next_id: next_id} = state ->
            new_plot = %Plot{plot_id: next_id, registered_to: register_to}
            updated = Map.put(registry, next_id, new_plot)
            {new_plot, %{state | registry: updated, next_id: next_id + 1}}
          end)
        end

        def release(pid, plot_id) do
          Agent.update(pid, fn %{registry: registry} = state ->
            updated = Map.delete(registry, plot_id)
            %{state | registry: updated}
          end)
        end

        def get_registration(pid, plot_id) do
          registration =
            Agent.get(pid, fn state ->
              state.registry[plot_id]
            end)

          case registration do
            nil -> {:not_found, "plot is unregistered"}
            _ -> registration
          end
        end
      end
    """
  end

  test_exercise_analysis "other reasonable solutions",
    comments: [] do
    [
      defmodule CommunityGarden do
        def start() do
          Agent.start(fn -> %{plots: [], id: 0} end)
        end

        def list_registrations(pid) do
          Agent.get(pid, fn %{plots: plots} -> plots end)
        end

        def register(pid, register_to) do
          Agent.get_and_update(pid, fn %{plots: plots, id: id} ->
            id = id + 1

            {%Plot{plot_id: id, registered_to: register_to},
             %{plots: [%Plot{plot_id: id, registered_to: register_to} | plots], id: id}}
          end)
        end

        def release(pid, plot_id) do
          Agent.cast(pid, fn %{plots: plots} = n ->
            plots = Enum.filter(plots, fn %{plot_id: x} -> x != plot_id end)
            %{n | plots: plots}
          end)
        end

        def get_registration(pid, plot_id) do
          case Enum.find(list_registrations(pid), fn _ -> plot_id end) do
            nil -> {:not_found, "plot is unregistered"}
            n -> n
          end
        end
      end,
      defmodule CommunityGarden do
        def start() do
          Agent.start(fn -> %{plots: [], index: 0} end)
        end

        def list_registrations(pid) do
          Agent.get(pid, fn %{plots: plots} -> plots end)
        end

        def register(pid, register_to) do
          Agent.get_and_update(pid, fn %{plots: plots, index: index} ->
            index = index + 1
            plot = %Plot{plot_id: index, registered_to: register_to}
            {plot, %{plots: [plot | plots], index: index}}
          end)
        end

        def release(pid, plot_id) do
          Agent.cast(pid, fn %{plots: plots} = status ->
            plots = Enum.filter(plots, fn %{plot_id: p} -> p !== plot_id end)
            %{status | plots: plots}
          end)
        end

        def get_registration(pid, plot_id) do
          Agent.get(pid, fn %{plots: plots} ->
            plots
            |> Enum.find(
              {:not_found, "plot is unregistered"},
              fn %{plot_id: p} -> p === plot_id end
            )
          end)
        end
      end
    ]
  end

  test_exercise_analysis "expects register to use Agent.get_and_update",
    comments_include: [Constants.community_garden_use_get_and_update()] do
    defmodule CommunityGarden do
      def register(pid, register_to) do
        state = Agent.get(pid, fn state -> state end)
        %{registry: registry, next_id: next_id} = state
        new_plot = %Plot{plot_id: next_id, registered_to: register_to}
        updated = Map.put(registry, next_id, new_plot)
        state = %{state | registry: updated, next_id: next_id + 1}
        Agent.update(pid, fn x -> state end)

        new_plot
      end
    end
  end
end
