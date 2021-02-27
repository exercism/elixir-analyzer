defmodule ElixirAnalyzer.TestSuite.TakeANumberTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.TakeANumber

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule TakeANumber do
      def start() do
        spawn(fn -> loop(0) end)
      end

      defp loop(state) do
        receive do
          {:report_state, sender_pid} ->
            send(sender_pid, state)
            loop(state)

          {:take_a_number, sender_pid} ->
            state = state + 1
            send(sender_pid, state)
            loop(state)

          :stop ->
            nil

          _ ->
            loop(state)
        end
      end
    end
  end

  describe "forbids abstractions" do
    test_exercise_analysis "detects Agent",
      comments_include: [Constants.take_a_number_do_not_use_abstractions()],
      status: :disapprove do
      defmodule TakeANumber do
        use Agent

        def start() do
          {:ok, agent_pid} = Agent.start_link(fn -> 0 end)
          spawn(fn -> loop(agent_pid) end)
        end

        defp loop(agent_pid) do
          receive do
            {:report_state, sender_pid} ->
              send(sender_pid, Agent.get(agent_pid, & &1))
              loop(agent_pid)

            {:take_a_number, sender_pid} ->
              send(sender_pid, Agent.get_and_update(agent_pid, &{&1 + 1, &1 + 1}))
              loop(agent_pid)

            :stop ->
              nil

            _ ->
              loop(agent_pid)
          end
        end
      end
    end

    test_exercise_analysis "detects GenServer",
      comments_include: [Constants.take_a_number_do_not_use_abstractions()],
      status: :disapprove do
      defmodule TakeANumber do
        use GenServer

        def start() do
          {:ok, pid} = GenServer.start_link(__MODULE__, [])
          pid
        end

        @impl true
        def init(_) do
          {:ok, 0}
        end

        @impl true
        def handle_info({:report_state, sender_pid}, state) do
          send(sender_pid, state)
          {:noreply, state}
        end

        @impl true
        def handle_info({:take_a_number, sender_pid}, state) do
          send(sender_pid, state + 1)
          {:noreply, state + 1}
        end

        @impl true
        def handle_info(:stop, state) do
          {:stop, :normal, state}
        end

        @impl true
        def handle_info(_, state) do
          {:noreply, state}
        end
      end
    end
  end
end
