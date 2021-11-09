defmodule ElixirAnalyzer.TestSuite.TopSecret do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Top Secret
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest,
    suppress_tests: [Constants.solution_use_function_capture()]

  assert_call "decode_secret_message/1 uses to_ast/1" do
    type :essential
    calling_fn module: TopSecret, name: :decode_secret_message
    called_fn module: TopSecret, name: :to_ast
    comment Constants.top_secret_function_reuse()
  end

  assert_call "decode_secret_message/1 uses decode_secret_message_part/2" do
    type :essential
    calling_fn module: TopSecret, name: :decode_secret_message
    called_fn module: TopSecret, name: :decode_secret_message_part
    comment Constants.top_secret_function_reuse()
  end

  feature "references decode_secret_message_part/2 by capturing it" do
    find :any
    type :actionable
    comment Constants.top_secret_function_capture()

    form do
      &decode_secret_message_part/2
    end
  end
end
