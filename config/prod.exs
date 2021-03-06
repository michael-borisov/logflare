use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# LogflareWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :logflare, LogflareWeb.Endpoint,
  http: [port: 4000, transport_options: [max_connections: "infinity", num_acceptors: 1_000]],
  url: [host: "logflare.app", scheme: "https"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  code_reloader: false,
  version: Application.spec(:logflare, :vsn)

#  secret_key_base: System.get_env("SECRET_KEY_BASE"),
#  session_cookie_name: System.get_env("SESSION_COOKIE_NAME"),
#  session_cookie_signing_salt: System.get_env("SESSION_COOKIE_SIGNING_SALT"),
#  session_cookie_encryption_salt: System.get_env("SESSION_COOKIE_ENCRYPTION_SALT")

# Do not print debug messages in production
config :logger, level: :error

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
# config :logflare, LogflareWeb.Endpoint,
#  url: [host: "logflare.app", port: 443],
#  https: [:inet6,
#          port: 443,
#          keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#          certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
# config :logflare, LogflareWeb.Endpoint,
#  force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :logflare, LogflareWeb.Endpoint, server: true
#

config :logflare, Logflare.Repo,
  pool_size: 15,
  ssl: true,
  prepare: :unnamed,
  timeout: 30_000

config :logflare, env: :prod
config :logflare, Logflare.Google,
  dataset_id_append: "_prod",
  project_number: "1074203751359",
  project_id: "logflare-232118",
  service_account: "logflare@logflare-232118.iam.gserviceaccount.com"

import_config "prod.secret.exs"
