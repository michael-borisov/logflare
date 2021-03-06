defmodule Logflare.SourceData do
  alias Logflare.SourceRateCounter
  alias Logflare.TableBuffer
  alias Logflare.TableCounter
  alias Logflare.Google.BigQuery

  @spec get_log_count(atom, String.t()) :: non_neg_integer()
  def get_log_count(token, bigquery_project_id) do
    case BigQuery.get_table(token, bigquery_project_id) do
      {:ok, table_info} ->
        table_rows = String.to_integer(table_info.numRows)

        buffer_rows =
          case is_nil(table_info.streamingBuffer) do
            true ->
              0

            false ->
              case is_nil(table_info.streamingBuffer.estimatedRows) do
                true ->
                  0

                false ->
                  String.to_integer(table_info.streamingBuffer.estimatedRows)
              end
          end

        table_rows + buffer_rows

      {:error, _message} ->
        0
    end
  end


  @spec get_ets_count(atom) :: non_neg_integer
  def get_ets_count(token) when is_atom(token) do
    log_table_info = :ets.info(token)

    case log_table_info do
      :undefined ->
        0

      _ ->
        log_table_info[:size]
    end
  end

  @spec get_total_inserts(atom) :: non_neg_integer
  def get_total_inserts(source_id) when is_atom(source_id) do
    log_table_info = :ets.info(source_id)

    case log_table_info do
      :undefined ->
        0

      _ ->
        {:ok, inserts} = TableCounter.get_total_inserts(source_id)
        inserts
    end
  end

  @spec get_rate(map) :: non_neg_integer
  def get_rate(%{id: _id, name: _name, token: source_token}) do
    {:ok, source_id} = Ecto.UUID.Atom.load(source_token)

    get_rate_int(source_id)
  end

  @spec get_rate(atom) :: non_neg_integer
  def get_rate(source_id) when is_atom(source_id) do
    get_rate_int(source_id)
  end

  @spec get_logs(atom) :: list(term)
  def get_logs(source_id) when is_atom(source_id) do
    case :ets.info(source_id) do
      :undefined ->
        []

      _ ->
        List.flatten(:ets.match(source_id, {:_, :"$1"}))
    end
  end

  @spec get_avg_rate(map) :: non_neg_integer
  def get_avg_rate(%{id: _id, name: _name, token: source_token}) do
    {:ok, source_id} = Ecto.UUID.Atom.load(source_token)

    case :ets.info(source_id) do
      :undefined ->
        0

      _ ->
        SourceRateCounter.get_avg_rate(source_id)
    end
  end

  @spec get_avg_rate(atom) :: non_neg_integer
  def get_avg_rate(source_id) when is_atom(source_id) do
    case :ets.info(source_id) do
      :undefined ->
        0

      _ ->
        SourceRateCounter.get_avg_rate(source_id)
    end
  end

  @spec get_max_rate(map) :: non_neg_integer
  def get_max_rate(%{id: _id, name: _name, token: source_token}) do
    {:ok, source_id} = Ecto.UUID.Atom.load(source_token)

    case :ets.info(source_id) do
      :undefined ->
        0

      _ ->
        SourceRateCounter.get_max_rate(source_id)
    end
  end

  @spec get_latest_date(map) :: non_neg_integer
  def get_latest_date(source, fallback \\ 0) do
    {:ok, source_id} = Ecto.UUID.Atom.load(source.token)

    case :ets.info(source_id) do
      :undefined ->
        fallback

      _ ->
        case :ets.last(source_id) do
          :"$end_of_table" ->
            fallback

          {timestamp, _unique_int, _monotime} ->
            timestamp
        end
    end
  end

  def get_buffer(token, fallback \\ 0) do
    case Process.whereis(String.to_atom("#{token}-buffer")) do
      nil ->
        fallback

      _ ->
        TableBuffer.get_count(token)
    end
  end

  @spec get_rate_int(atom) :: non_neg_integer
  defp get_rate_int(source_id) do
    case :ets.info(source_id) do
      :undefined ->
        0

      _ ->
        SourceRateCounter.get_rate(source_id)
    end
  end
end
