defmodule Csv.Spec do
  @moduledoc false

  defmacro __using__(opts) do
    {fields, titles} =
      opts
      |> Keyword.get(:columns, [])
      |> Enum.unzip()

    parser = Keyword.fetch!(opts, :parser)

    quote bind_quoted: [
            fields: fields,
            parser: parser,
            titles: titles
          ] do
      spec_module = __MODULE__

      defmodule Builder do
        @moduledoc false
        @fields fields
        @header [titles] |> parser.dump_to_iodata() |> hd()
        @module spec_module
        @parser parser

        if fields == [] do
          def new(items) when is_list(items) do
            []
          end
        else
          def new(items) when is_list(items) do
            rows =
              items
              |> Stream.map(&row/1)
              |> @parser.dump_to_stream()
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
        @spec unquote(field)(%{atom() => any()}) :: term()
        @doc false
        def unquote(field)(item) do
          unless Map.has_key?(item, unquote(field)) do
            raise ArgumentError,
              message: """
              Key `#{unquote(field)}` not found. Add a function \
              named `#{inspect(__MODULE__)}.#{unquote(field)}/1` \
              to create a virtual column. Otherwise, ensure \
              that `Csv.Spec` is configured correctly, or the \
              data you provided is accurate: `#{inspect(item)}`
              """
          end

          item.unquote(field)
        end

        defoverridable [{field, 1}]
      end
    end
  end
end
