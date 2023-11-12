defmodule Csv.Spec do
  @moduledoc false

  defmacro __using__(opts) do
    {fields, titles} =
      opts
      |> Keyword.get(:columns, [])
      |> Enum.unzip()

    quote bind_quoted: [fields: fields, titles: titles] do
      if fields == [] do
        def rows(items) when is_list(items) do
          []
        end
      else
        def rows(items) when is_list(items) do
          rows =
            for item <- items do
              for field <- unquote(fields) do
                apply(__MODULE__, field, [item])
              end
            end

          [unquote(titles) | rows]
        end
      end

      for field <- fields do
        @spec unquote(field)(%{atom() => any()}) :: term()
        def unquote(field)(item) do
          unless Map.has_key?(item, unquote(field)) do
            raise ArgumentError,
              message: """
              Key `#{unquote(field)}` not found. Add a function to \
              `#{inspect(__MODULE__)}.#{unquote(field)}/1` \
              to create a virtual column. Otherwise, ensure \
              that the configured `Csv.Spec` and provided \
              data are accurate: `#{inspect(item)}`
              """
          end

          item[unquote(field)]
        end

        defoverridable [{field, 1}]
      end
    end
  end
end
