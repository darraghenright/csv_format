# CsvFormat

## Description

WIP

## Dependencies

Requires [`nimble_csv`](https://github.com/dashbitco/nimble_csv) or any module that implements the `NimbleCSV` behaviour. specifically callbacks [`dump_to_iodata/1`](https://github.com/dashbitco/nimble_csv/blob/master/lib/nimble_csv.ex#L97) and [`dump_to_stream/1`](https://github.com/dashbitco/nimble_csv/blob/master/lib/nimble_csv.ex#L104).

## Usage

Using the following example — a list of employees:

```elixir
employees = [
  %{
    id: 1,
    date_of_birth: ~D[1990-05-15],
    first_name: "Emma",
    last_name: "Johnson",
    role: "Software Engineer"
  },
  %{
    id: 2,
    date_of_birth: ~D[1985-11-28],
    first_name: "Alex",
    last_name: "Martinez",
    role: "Marketing Manager"
  }
]
```

Create a CSV specification:

```elixir
defmodule EmployeeCsv do
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    columns: [
      id: "#",
      first_name: "First name",
      last_name: "Last name",
      role: "Role"
    ]
end
```

Then build the CSV.:

```elixir
csv = EmployeeCsv.Builder.new(employees)
```

And print the result:

```
#,Role,First name,Last name\r\n
1,Software Engineer,Emma,Johnson\r\n
2,Marketing Manager,Alex,Martinez\r\n
```

### Customise columns

You can optionally customise formatting of individual fields by defining a function with the same name as the field; e.g:

```elixir
defmodule EmployeeCsv do
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    columns: [
      id: "#",
      date_of_birth: "Date of birth"
    ]

  def date_of_birth(employee) do
    Calendar.strftime(employee.date_of_birth, "%d/%m/%Y")
  end
end
```

Build the CSV:

```elixir
csv = EmployeeCsv.Builder.new(employees)
```

And print the result:

```
#,Date of birth\r\n
1,15/05/1990\r\n
2,28/11/1985\r\n
```

### Virtual columns

You can also create virtual columns. Columns you declare in the `CsvFormat.Spec` don't have to exist in the source data:

```elixir
defmodule EmployeeCsv do
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    columns: [
      full_name: "Full name"
    ]

  def full_name(employee) do
    "#{employee.first_name} #{employee.last_name}"
  end
end
```

Virtual columns are not optional; you must define a function. A `KeyError` is raised to remind you if you forget.
