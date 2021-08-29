defmodule ElixirAnalyzer.TestSuite.Newsletter do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Newsletter 
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  feature "close_log ends with File.close" do
    type :actionable
    comment Constants.newsletter_close_log_returns_implicitly()

    form do
      def close_log(_ignore) do
        _block_ends_with do
          File.close(_ignore)
        end
      end
    end
  end

  feature "log_sent_email ends with IO.puts" do
    type :actionable
    comment Constants.newsletter_log_sent_email_returns_implicitly()

    form do
      def log_sent_email(_ignore, _ignore) do
        _block_ends_with do
          IO.puts(_ignore, _ignore)
        end
      end
    end
  end

  feature "send_newsletter ends with close_log" do
    type :actionable
    comment Constants.newsletter_send_newsletter_returns_implicitly()

    form do
      def send_newsletter(_ignore, _ignore, _ignore) do
        _block_ends_with do
          close_log(_ignore)
        end
      end
    end
  end

  feature "open_log used the option :write" do
    type :essential
    comment Constants.newsletter_open_log_uses_option_write()

    form do
      def open_log(_ignore) do
        _block_includes do
          File.open!(_ignore, [:write])
        end
      end
    end
  end

  assert_no_call "send_newsletter/3 doesn't use File.write" do
    type :essential
    comment ElixirAnalyzer.Constants.newsletter_send_newsletter_does_not_call_write()
    called_fn module: File, name: :write
    calling_fn module: Newsletter, name: :send_newsletter
  end

  assert_no_call "send_newsletter/3 doesn't use File.write!" do
    type :essential
    comment ElixirAnalyzer.Constants.newsletter_send_newsletter_does_not_call_write()
    called_fn module: File, name: :write!
    calling_fn module: Newsletter, name: :send_newsletter
  end
end
