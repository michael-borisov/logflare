defmodule Logflare.SourcesTest do
  @moduledoc false
  alias Logflare.Sources.Cache
  import Cache
  use Logflare.DataCase
  import Logflare.DummyFactory
  alias Logflare.{Repo, User, Source}

  setup do
    r1 = insert(:rule)
    r2 = insert(:rule)
    source = insert(:source, token: Faker.UUID.v4(), rules: [r1, r2])
    _s2 = insert(:source, token: Faker.UUID.v4())
    {:ok, source: source}
  end

  describe "source cache" do
    test "get_by_id/1", %{source: source} do
      left_source = get_by_id(source.token)
      assert left_source.id == source.id
      assert left_source.inserted_at == source.inserted_at
      assert is_list(left_source.rules)
      assert length(left_source.rules) == 2
    end
  end
end
