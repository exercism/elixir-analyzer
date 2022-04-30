defmodule ElixirAnalyzer.TestSuite.TakeANumberDeluxeTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.TakeANumberDeluxe

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    defmodule TakeANumberDeluxe do
      use GenServer

      # Client API

      @spec start_link(keyword()) :: {:ok, pid()} | {:error, atom()}
      def start_link(init_arg) do
        GenServer.start_link(__MODULE__, init_arg)
      end

      @spec report_state(pid()) :: TakeANumberDeluxe.State.t()
      def report_state(machine) do
        GenServer.call(machine, :report_state)
      end

      @spec queue_new_number(pid()) :: {:ok, integer()} | {:error, atom()}
      def queue_new_number(machine) do
        GenServer.call(machine, :queue_new_number)
      end

      @spec serve_next_queued_number(pid(), integer() | nil) ::
              {:ok, integer()} | {:error, atom()}
      def serve_next_queued_number(machine, priority_number \\ nil) do
        GenServer.call(machine, {:serve_next_queued_number, priority_number})
      end

      @spec reset_state(pid()) :: :ok
      def reset_state(machine) do
        GenServer.cast(machine, :reset_state)
      end

      # Server callbacks

      @impl GenServer
      def init(init_arg) do
        min_number = Keyword.get(init_arg, :min_number)
        max_number = Keyword.get(init_arg, :max_number)
        auto_shutdown_timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)

        case TakeANumberDeluxe.State.new(min_number, max_number, auto_shutdown_timeout) do
          {:ok, state} -> {:ok, state, auto_shutdown_timeout}
          {:error, error} -> {:stop, error}
        end
      end

      @impl GenServer
      def handle_call(:report_state, _from, state) do
        {:reply, state, state, state.auto_shutdown_timeout}
      end

      @impl GenServer
      def handle_call(:queue_new_number, _from, state) do
        case TakeANumberDeluxe.State.queue_new_number(state) do
          {:ok, new_number, new_state} ->
            {:reply, {:ok, new_number}, new_state, state.auto_shutdown_timeout}

          {:error, error} ->
            {:reply, {:error, error}, state, state.auto_shutdown_timeout}
        end
      end

      @impl GenServer
      def handle_call({:serve_next_queued_number, priority_number}, _from, state) do
        case TakeANumberDeluxe.State.serve_next_queued_number(state, priority_number) do
          {:ok, next_number, new_state} ->
            {:reply, {:ok, next_number}, new_state, state.auto_shutdown_timeout}

          {:error, error} ->
            {:reply, {:error, error}, state, state.auto_shutdown_timeout}
        end
      end

      @impl GenServer
      def handle_cast(:reset_state, state) do
        {:ok, state} =
          TakeANumberDeluxe.State.new(
            state.min_number,
            state.max_number,
            state.auto_shutdown_timeout
          )

        {:noreply, state, state.auto_shutdown_timeout}
      end

      @impl GenServer
      def handle_info(:timeout, state) do
        {:stop, :normal, state}
      end

      @impl GenServer
      def handle_info(_, state) do
        {:noreply, state, state.auto_shutdown_timeout}
      end
    end
  end

  describe "must `use` GenServer" do
    test_exercise_analysis "forgot `use`",
      comments_include: [Constants.take_a_number_deluxe_use_genserver()] do
      defmodule TakeANumberDeluxe do
        @spec start_link(keyword()) :: {:ok, pid()} | {:error, atom()}
        def start_link(init_arg) do
          GenServer.start_link(__MODULE__, init_arg)
        end
      end
    end

    test_exercise_analysis "used `use`",
      comments_exclude: [Constants.take_a_number_deluxe_use_genserver()] do
      defmodule TakeANumberDeluxe do
        use GenServer

        @spec start_link(keyword()) :: {:ok, pid()} | {:error, atom()}
        def start_link(init_arg) do
          GenServer.start_link(__MODULE__, init_arg)
        end
      end
    end
  end

  describe "must annotate with `@impl GenServer`" do
    test_exercise_analysis "forgot `@impl` entirely",
      comments_include: [Constants.take_a_number_deluxe_annotate_impl_genserver()] do
      defmodule TakeANumberDeluxe do
        use GenServer

        def init(init_arg) do
          min_number = Keyword.get(init_arg, :min_number)
          max_number = Keyword.get(init_arg, :max_number)
          auto_shutdown_timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)

          case TakeANumberDeluxe.State.new(min_number, max_number, auto_shutdown_timeout) do
            {:ok, state} -> {:ok, state, auto_shutdown_timeout}
            {:error, error} -> {:stop, error}
          end
        end

        def handle_call(:report_state, _from, state) do
          {:reply, state, state, state.auto_shutdown_timeout}
        end
      end
    end

    test_exercise_analysis "value must be a module",
      comments_include: [Constants.take_a_number_deluxe_annotate_impl_genserver()] do
      defmodule TakeANumberDeluxe do
        use GenServer

        @impl true
        def init(init_arg) do
          min_number = Keyword.get(init_arg, :min_number)
          max_number = Keyword.get(init_arg, :max_number)
          auto_shutdown_timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)

          case TakeANumberDeluxe.State.new(min_number, max_number, auto_shutdown_timeout) do
            {:ok, state} -> {:ok, state, auto_shutdown_timeout}
            {:error, error} -> {:stop, error}
          end
        end

        @impl true
        def handle_call(:report_state, _from, state) do
          {:reply, state, state, state.auto_shutdown_timeout}
        end
      end
    end

    test_exercise_analysis "used at least once is enough",
      comments_exclude: [Constants.take_a_number_deluxe_annotate_impl_genserver()] do
      [
        defmodule TakeANumberDeluxe do
          use GenServer

          @impl GenServer
          def init(init_arg) do
            min_number = Keyword.get(init_arg, :min_number)
            max_number = Keyword.get(init_arg, :max_number)
            auto_shutdown_timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)

            case TakeANumberDeluxe.State.new(min_number, max_number, auto_shutdown_timeout) do
              {:ok, state} -> {:ok, state, auto_shutdown_timeout}
              {:error, error} -> {:stop, error}
            end
          end

          @impl GenServer
          def handle_call(:report_state, _from, state) do
            {:reply, state, state, state.auto_shutdown_timeout}
          end
        end,
        defmodule TakeANumberDeluxe do
          use GenServer

          def init(init_arg) do
            min_number = Keyword.get(init_arg, :min_number)
            max_number = Keyword.get(init_arg, :max_number)
            auto_shutdown_timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)

            case TakeANumberDeluxe.State.new(min_number, max_number, auto_shutdown_timeout) do
              {:ok, state} -> {:ok, state, auto_shutdown_timeout}
              {:error, error} -> {:stop, error}
            end
          end

          @impl GenServer
          def handle_call(:report_state, _from, state) do
            {:reply, state, state, state.auto_shutdown_timeout}
          end
        end
      ]
    end
  end
end
