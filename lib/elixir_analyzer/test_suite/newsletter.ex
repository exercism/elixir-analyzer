defmodule ElixirAnalyzer.TestSuite.Newsletter do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Newsletter
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  feature "close_log ends with File.close" do
    type :actionable
    find :none
    comment Constants.newsletter_close_log_returns_implicitly()

    form do
      def close_log(_ignore) do
        _block_ends_with do
          :ok
        end
      end
    end

    form do
      def close_log(_ignore) when _ignore do
        _block_ends_with do
          :ok
        end
      end
    end
  end

  feature "use IO.puts in log_sent_email rather than IO.write as last call" do
    find :none
    type :actionable
    comment Constants.newsletter_log_sent_email_prefer_io_puts()

    form do
      def log_sent_email(_ignore, _ignore) do
        _block_ends_with do
          IO.write(_ignore, _ignore)
        end
      end
    end

    form do
      def log_sent_email(_ignore, _ignore) when _ignore do
        _block_ends_with do
          :ok
        end
      end
    end
  end

  assert_no_call "use IO.puts in log_sent_email rather than IO.write" do
    type :actionable
    calling_fn module: Newsletter, name: :log_sent_email
    called_fn module: IO, name: :write
    comment Constants.newsletter_log_sent_email_prefer_io_puts()
  end

  feature "log_sent_email ends with IO.puts" do
    type :actionable
    find :none
    comment Constants.newsletter_log_sent_email_returns_implicitly()
    suppress_if "use IO.puts in log_sent_email rather than IO.write as last call", :fail

    form do
      def log_sent_email(_ignore, _ignore) do
        _block_ends_with do
          :ok
        end
      end
    end

    form do
      def log_sent_email(_ignore, _ignore) when _ignore do
        _block_ends_with do
          :ok
        end
      end
    end
  end

  feature "send_newsletter ends with close_log" do
    type :actionable
    find :none
    comment Constants.newsletter_send_newsletter_returns_implicitly()

    form do
      def send_newsletter(_ignore, _ignore, _ignore) do
        _block_ends_with do
          :ok
        end
      end
    end

    form do
      def send_newsletter(_ignore, _ignore, _ignore) when _ignore do
        _block_ends_with do
          :ok
        end
      end
    end
  end

  feature "open_log used the option :write" do
    find :any
    type :essential
    comment Constants.newsletter_open_log_uses_option_write()

    form do
      def open_log(_ignore) do
        _block_includes do
          File.open(_ignore, [:write])
        end
      end
    end

    form do
      def open_log(_ignore) do
        _block_includes do
          File.open!(_ignore, [:write])
        end
      end
    end

    form do
      def open_log(_ignore) do
        _block_includes do
          open(_ignore, [:write])
        end
      end
    end

    form do
      def open_log(_ignore) do
        _block_includes do
          open!(_ignore, [:write])
        end
      end
    end

    form do
      def open_log(_ignore) when _ignore do
        _block_includes do
          File.open!(_ignore, [:write])
        end
      end
    end
  end

  assert_call "send_newsletter/3 calls open_log/1" do
    type :actionable
    comment Constants.newsletter_send_newsletter_reuses_functions()
    called_fn name: :open_log
    calling_fn module: Newsletter, name: :send_newsletter
  end

  assert_call "send_newsletter/3 calls close_log/1" do
    type :actionable
    comment Constants.newsletter_send_newsletter_reuses_functions()
    called_fn name: :close_log
    calling_fn module: Newsletter, name: :send_newsletter
  end

  assert_call "send_newsletter/3 calls read_emails/1" do
    type :actionable
    comment Constants.newsletter_send_newsletter_reuses_functions()
    called_fn name: :read_emails
    calling_fn module: Newsletter, name: :send_newsletter
  end

  assert_call "send_newsletter/3 calls log_sent_email/2" do
    type :actionable
    comment Constants.newsletter_send_newsletter_reuses_functions()
    called_fn name: :log_sent_email
    calling_fn module: Newsletter, name: :send_newsletter
  end
end
