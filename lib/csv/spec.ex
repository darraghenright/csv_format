defmodule Csv.Spec do
  @moduledoc false

  defmacro __using__(opts) do
    {fields, titles} =
      opts
      |> Keyword.get(:columns, [])
      |> Enum.unzip()

    quote bind_quoted: [fields: fields, titles: titles] do
      if fields == [] do
        def rows(items) do
          []
        end
      else
        def rows(items) do
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
        def unquote(field)(item) do
          item[unquote(field)]
        end

        defoverridable [{field, 1}]
      end
    end
  end
end
