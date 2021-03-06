defmodule LogflareWeb.Plugs.RateLimiter do
  @moduledoc """
  A plug that allows or denies API action based on the API request rate rules for user/source
  """
  alias Logflare.{Users, User}
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    user =
      case conn.assigns.user do
        api_key when is_binary(api_key) -> Users.Cache.find_user_by_api_key(api_key)
        %User{} = u -> u
      end

    result =
      verify_api_rates_quotas(%{
        user: user,
        source_id: conn.assigns.source.token,
        type: {:api_call, :logs_post}
      })

    case result do
      {:ok, %{metrics: metrics}} ->
        conn
        |> put_x_rate_limit_headers(metrics)

      {:error, %{message: message, metrics: metrics}} ->
        conn
        |> put_x_rate_limit_headers(metrics)
        |> send_resp(429, message)
        |> halt()
    end
  end

  def put_x_rate_limit_headers(conn, metrics) do
    metrics = Iteraptor.map(metrics, fn {_, int} -> Integer.to_string(int) end)

    conn
    |> put_resp_header("x-rate-limit-user_limit", metrics.user.limit)
    |> put_resp_header("x-rate-limit-user_remaining", metrics.user.remaining)
    |> put_resp_header("x-rate-limit-source_limit", metrics.source.limit)
    |> put_resp_header("x-rate-limit-source_remaining", metrics.source.remaining)
  end

  def verify_api_rates_quotas(action) do
    Logflare.Users.API.verify_api_rates_quotas(action)
  end
end
