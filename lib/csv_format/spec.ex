defmodule CsvFormat.Spec do
  @moduledoc false

  defmacro __using__(opts) do
    {fields, titles} =
      opts
      |> Keyword.get(:columns, [])
      |> Enum.unzip()

    dumper = Keyword.fetch!(opts, :dumper)

    quote bind_quoted: [
            dumper: dumper,
            fields: fields,
            titles: titles
          ] do
      spec_module = __MODULE__

      defmodule Builder do
        @moduledoc false
        @dumper dumper
        @fields fields
        @header [titles] |> dumper.dump_to_iodata() |> hd()
        @module spec_module

        if fields == [] do
          @spec new([%{atom() => term()}]) :: []
          def new(items) when is_list(items) do
            []
          end
        else
          @spec new([%{atom() => term()}]) :: [iodata()]
          def new(items) when is_list(items) do
            rows =
              items
              |> Stream.map(&row/1)
              |> @dumper.dump_to_stream()
              |> Enum.to_list()

            [@header | rows]
          end
        end

        defp row(item) do
          for field <- @fields do
            apply(@module, field, [item])
          end
        end
      end

      for field <- fields do
        @doc false
        @spec unquote(field)(%{atom() => term()}) :: term()
        # credo:disable-for-next-line
        def unquote(field)(item) do
          item.unquote(field)
        rescue
          e in KeyError ->
            message = """
            Key `#{e.key}` not found. Add a function named `#{inspect(__MODULE__)}.#{e.key}/1` \
            to create a virtual column. Otherwise, ensure that `CsvFormat.Spec` is configured \
            correctly, or the data you provided is accurate: `#{inspect(e.term)}`
            """

            reraise KeyError, [message: message], __STACKTRACE__
        end

        defoverridable [{field, 1}]
      end
    end
  end
end
