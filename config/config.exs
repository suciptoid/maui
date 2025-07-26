# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

esbuild = fn args ->
  [
    args: ~w(js/index.js --bundle --external:phoenix_live_view --alias:@=.) ++ args,
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]
end

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  module: esbuild.(~w(--format=esm --sourcemap --outfile=../priv/static/maui.mjs)),
  main: esbuild.(~w(--format=cjs --sourcemap --outfile=../priv/static/maui.cjs.js))
