defmodule ElixirAnalyzer.ExerciseTest.NewsletterTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.Newsletter

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule Newsletter do
      def read_emails(path) do
        path
        |> File.read!()
        |> String.split()
      end

      def open_log(path) do
        File.open!(path, [:write])
      end

      def log_sent_email(pid, email) do
        IO.puts(pid, email)
      end

      def close_log(pid) do
        File.close(pid)
      end

      def send_newsletter(emails_path, log_path, send_fun) do
        log_pid = open_log(log_path)
        emails = read_emails(emails_path)

        Enum.each(emails, fn email ->
          case send_fun.(email) do
            :ok -> log_sent_email(log_pid, email)
            _ -> nil
          end
        end)

        close_log(log_pid)
      end
    end
  end

  describe "detects non-implicit returns" do
    test_exercise_analysis "explicit return in close_log",
      comments_include: [Constants.newsletter_close_log_returns_implicitly()] do
      [
        defmodule Newsletter do
          def close_log(pid) do
            File.close(pid)
            :ok
          end
        end,
        defmodule Newsletter do
          def close_log(pid) do
            x = File.close(pid)
            x
          end
        end
      ]
    end

    test_exercise_analysis "explicit return in log_sent_email",
      comments_include: [Constants.newsletter_log_sent_email_returns_implicitly()] do
      [
        defmodule Newsletter do
          def log_sent_email(pid, email) do
            IO.puts(pid, email)
            :ok
          end
        end,
        defmodule Newsletter do
          def log_sent_email(pid, email) do
            x = IO.puts(pid, email)
            x
          end
        end
      ]
    end

    test_exercise_analysis "explicit return in send_newsletter",
      comments_include: [Constants.newsletter_send_newsletter_returns_implicitly()] do
      [
        defmodule Newsletter do
          def send_newsletter(emails_path, log_path, send_fun) do
            log_pid = open_log(log_path)
            emails = read_emails(emails_path)

            Enum.each(emails, fn email ->
              case send_fun.(email) do
                :ok -> log_sent_email(log_pid, email)
                _ -> nil
              end
            end)

            close_log(log_pid)
            :ok
          end
        end,
        defmodule Newsletter do
          def send_newsletter(emails_path, log_path, send_fun) do
            log_pid = open_log(log_path)
            emails = read_emails(emails_path)

            Enum.each(emails, fn email ->
              case send_fun.(email) do
                :ok -> log_sent_email(log_pid, email)
                _ -> nil
              end
            end)

            x = close_log(log_pid)
            x
          end
        end
      ]
    end
  end

  test_exercise_analysis "open_log uses :append",
    comments_include: [Constants.newsletter_open_log_uses_option_write()] do
    [
      defmodule Newsletter do
        def open_log(path) do
          File.open(path, [:append])
        end

        def send_newsletter(emails_path, log_path, send_fun) do
          emails = read_emails(emails_path)

          Enum.each(emails, fn email ->
            log_pid = open_log(log_path)

            case send_fun.(email) do
              :ok -> log_sent_email(log_pid, email)
              _ -> nil
            end

            close_log(log_pid)
          end)
        end
      end,
      defmodule Newsletter do
        def open_log(path) do
          File.open!(path, [:append])
        end

        def send_newsletter(emails_path, log_path, send_fun) do
          emails = read_emails(emails_path)

          Enum.each(emails, fn email ->
            log_pid = open_log(log_path)

            case send_fun.(email) do
              :ok -> log_sent_email(log_pid, email)
              _ -> nil
            end

            close_log(log_pid)
          end)
        end
      end
    ]
  end

  describe "send_newsletter doesn't reuse other functions" do
    test_exercise_analysis "send_newsletter doesn't use open_log",
      comments_include: [Constants.newsletter_send_newsletter_reuses_functions()] do
      defmodule Newsletter do
        def send_newsletter(emails_path, log_path, send_fun) do
          log_pid = File.open!(path, [:write])
          emails = read_emails(emails_path)

          Enum.each(emails, fn email ->
            case send_fun.(email) do
              :ok -> log_sent_email(log_pid, email)
              _ -> nil
            end
          end)

          close_log(log_pid)
        end
      end
    end

    test_exercise_analysis "send_newsletter doesn't use close_log",
      comments_include: [Constants.newsletter_send_newsletter_reuses_functions()] do
      defmodule Newsletter do
        def send_newsletter(emails_path, log_path, send_fun) do
          log_pid = open_log(log_path)
          emails = read_emails(emails_path)

          Enum.each(emails, fn email ->
            case send_fun.(email) do
              :ok -> log_sent_email(log_pid, email)
              _ -> nil
            end
          end)

          File.close(log_pid)
        end
      end
    end

    test_exercise_analysis "send_newsletter doesn't use read_emails",
      comments_include: [Constants.newsletter_send_newsletter_reuses_functions()] do
      defmodule Newsletter do
        def send_newsletter(emails_path, log_path, send_fun) do
          log_pid = open_log(log_path)

          emails_path
          |> File.read!()
          |> String.split()
          |> Enum.each(fn email ->
            case send_fun.(email) do
              :ok -> log_sent_email(log_pid, email)
              _ -> nil
            end
          end)

          close_log(log_pid)
        end
      end
    end

    test_exercise_analysis "send_newsletter doesn't use log_sent_email",
      comments_include: [Constants.newsletter_send_newsletter_reuses_functions()] do
      defmodule Newsletter do
        def send_newsletter(emails_path, log_path, send_fun) do
          log_pid = open_log(log_path)
          emails = read_emails(emails_path)

          Enum.each(emails, fn email ->
            case send_fun.(email) do
              :ok -> IO.puts(log_pid, email)
              _ -> nil
            end
          end)

          close_log(log_pid)
        end
      end
    end
  end
end
