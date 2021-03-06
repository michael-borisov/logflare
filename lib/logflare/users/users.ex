defmodule Logflare.Users do
  alias Logflare.{User, Source}
  alias Logflare.Repo
  @moduledoc false

  def get_user_by_id(id) when is_integer(id) do
    User
    |> Repo.get(id)
    |> Repo.preload(:sources)
  end

  def get_api_quotas(%User{} = user, %Source{} = source) do
    source = Enum.find(user.sources, &(&1.id === source))

    %{
      user: user.api_quota,
      source: source.api_quota
    }
  end

  @spec find_user_by_api_key(String.t()) :: User.t() | nil
  def find_user_by_api_key(nil), do: nil

  def find_user_by_api_key(api_key) when is_binary(api_key) do
    User
    |> Repo.get_by(api_key: api_key)
    |> Repo.preload(:sources)
  end
end
