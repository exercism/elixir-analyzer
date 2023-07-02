defmodule ElixirAnalyzer.ConstantsTest do
  use ExUnit.Case
  doctest ElixirAnalyzer

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Support

  setup_all do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    :ok
  end

  test "check mock constant" do
    assert Support.Constants.mock_constant() == "mock.constant"
  end

  describe "if comment exists at exercism/website-copy" do
    @comments Constants.list_of_all_comments()
    @website_copy_url "https://github.com/exercism/website-copy/blob/master/analyzer-comments/"
    @file_ext ".md"

    for comment <- @comments do
      @comment comment
      @tag :external
      test "#{@comment} exists" do
        request_path = String.replace(@comment, ".", "/")
        request_url = "#{@website_copy_url}#{request_path}#{@file_ext}" |> to_charlist()

        {status, status_msg} = get_comment_with_retry_on_rate_limit_error(request_url)

        assert {status, status_msg, @comment} == {200, ~c"OK", @comment}
      end
    end
  end

  defp get_comment_with_retry_on_rate_limit_error(request_url) do
    {:ok, {{~c"HTTP/1.1", status, status_msg}, _headers, _body}} =
      :httpc.request(:head, {request_url, []}, [], [])

    if status == 429 do
      :timer.sleep(300)
      get_comment_with_retry_on_rate_limit_error(request_url)
    else
      {status, status_msg}
    end
  end
end
