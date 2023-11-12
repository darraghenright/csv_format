defmodule ZeroColumnCsv do
  @moduledoc """
  CSV with no defined columns.
  """
  use Csv.Spec
end

defmodule EmployeeCsv do
  @moduledoc false
  use Csv.Spec,
    columns: [
      id: "#",
      role: "Role",
      first_name: "First name",
      last_name: "Last name"
    ]
end

defmodule EmployeeCsvWithCustomColumn do
  @moduledoc false
  use Csv.Spec,
    columns: [
      id: "#",
      date_of_birth: "Date of Birth"
    ]

  @doc """
  Customise the formatting of
  an employee's date of birth.
  """
  def date_of_birth(employee) do
    Calendar.strftime(employee.date_of_birth, "%d/%m/%Y")
  end
end

defmodule EmployeeCsvWithVirtualColumn do
  @moduledoc false
  use Csv.Spec,
    columns: [
      id: "#",
      full_name: "Full name"
    ]

  @doc """
  Declare a custom value for a column
  that does not exist in source data.
  """
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
  use Csv.Spec,
    columns: [
      id: "#",
      full_name: "Full name"
    ]
end

ExUnit.start()
