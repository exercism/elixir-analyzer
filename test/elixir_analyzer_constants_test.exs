defmodule ElixirAnalyzerConstantsTest do
  use ExUnit.Case
  doctest ElixirAnalyzer

  alias ElixirAnalyzer.Constants

  setup_all do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    :ok
  end

  describe "if comment exists at exercism/website-copy" do
    @comments Constants.list_of_all_comments()
    @website_copy_url "https://github.com/exercism/website-copy/blob/master/automated-comments/"
    @file_ext ".md"

    for comment <- @comments do
      @comment comment
      @tag :external
      test "#{@comment} exists" do
        request_path = String.replace(@comment, ".", "/")
        request_url = "#{@website_copy_url}#{request_path}#{@file_ext}" |> to_charlist()

        {:ok, {{'HTTP/1.1', status, status_msg}, _headers, _body}} =
          :httpc.request(:head, {request_url, []}, [], [])

        assert status == 200
        assert status_msg == 'OK'
      end
    end
  end
end
