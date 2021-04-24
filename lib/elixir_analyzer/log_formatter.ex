defmodule ElixirAnalyzer.LogFormatter do
  @moduledoc """
  Analyzer's custom formatter for the Logger.
  """

  def format(level, message, timestamp, metadata) do
    "# #{fmt_timestamp(timestamp)} #{inspect(metadata)} [#{level}] #{message}\n"
  rescue
    _ -> "could not format message: #{inspect({level, message, timestamp, metadata})}\n"
  end

  defp fmt_timestamp({date, {hh, mm, ss, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}, {ms * 1000, 3}),
         result <- NaiveDateTime.to_iso8601(timestamp) do
      "#{result}Z"
    end
  end
end
