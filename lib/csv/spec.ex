defmodule Csv.Spec do
  @moduledoc false

  defmacro __using__(opts) do
    columns = Keyword.get(opts, :columns, [])

    {fields, titles} = Enum.unzip(columns)

    quote bind_quoted: [fields: fields, titles: titles] do
      def rows(items) do
        rows(items, unquote(fields), unquote(titles))
      end

      defp rows(_items, [], []) do
        []
      end

      defp rows(items, fields, titles) do
        rows =
          for item <- items do
            for field <- unquote(fields) do
              apply(__MODULE__, field, [item])
            end
          end

        [titles | rows]
      end

      for field <- fields do
        def unquote(field)(item) do
          item[unquote(field)]
        end

        defoverridable [{field, 1}]
      end
    end
  end
end
