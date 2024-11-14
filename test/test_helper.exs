defmodule Employee do
  @moduledoc false
  defstruct [:id, :date_of_birth, :first_name, :last_name, :role]
end

defmodule ZeroColumnCsv do
  @moduledoc """
  CSV with no defined columns.
  """
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180
end

defmodule EmployeeCsv do
  @moduledoc false
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    columns: [
      id: "#",
      role: "Role",
      first_name: "First name",
      last_name: "Last name"
    ]
end

defmodule EmployeeCsvWithoutHeader do
  @moduledoc false
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    skip_header: true,
    columns: [
      id: "#",
      role: "Role",
      first_name: "First name",
      last_name: "Last name"
    ]
end

defmodule EmployeeCsvWithCustomColumn do
  @moduledoc false
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    columns: [
      id: "#",
      date_of_birth: "Date of Birth"
    ]

  @doc """
  Customise the formatting of
  an employee's date of birth.
  """
  @spec date_of_birth(%{atom() => any()}) :: String.t()
  def date_of_birth(employee) do
    Calendar.strftime(employee.date_of_birth, "%d/%m/%Y")
  end
end

defmodule EmployeeCsvWithVirtualColumn do
  @moduledoc false
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    columns: [
      id: "#",
      full_name: "Full name"
    ]

  @doc """
  Declare a custom value for a column
  that does not exist in source data.
  """
  @spec full_name(%{atom() => any()}) :: String.t()
  def full_name(employee) do
    "#{employee.first_name} #{employee.last_name}"
  end
end

defmodule EmployeeCsvWithMissingVirtualColumn do
  @moduledoc """
  CSV that does not declare a function
  for virtual column `full_name` which
  would be required at runtime.
  """
  use CsvFormat.Spec,
    dumper: NimbleCSV.RFC4180,
    columns: [
      id: "#",
      full_name: "Full name"
    ]
end

ExUnit.start()
