ExUnit.start(autorun: false)
ExUnit.configure(exclude: :pending, trace: true)

Code.require_file("two_fer.exs", __DIR__)
Code.require_file("two_fer_test.exs", __DIR__)

ExUnit.Server.modules_loaded()

ExUnit.run()

