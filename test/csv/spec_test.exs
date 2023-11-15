defmodule Csv.SpecTest do
  @moduledoc false
  use ExUnit.Case
  import IO, only: [iodata_to_binary: 1]

  @employees [
    %{
      id: 1,
      date_of_birth: Date.from_iso8601!("1990-05-15"),
      first_name: "Emma",
      last_name: "Johnson",
      role: "Software Engineer"
    },
    %{
      id: 2,
      date_of_birth: Date.from_iso8601!("1985-11-28"),
      first_name: "Alex",
      last_name: "Martinez",
      role: "Marketing Manager"
    }
  ]

  test "a spec that declares no columns should build an empty csv" do
    csv = ZeroColumnCsv.Builder.new(@employees)

    assert iodata_to_binary(csv) == ""
  end

  test "a spec that declares no columns and no data should build an empty csv" do
    csv = ZeroColumnCsv.Builder.new([])

    assert iodata_to_binary(csv) == ""
  end

  test "a spec that takes no data should build headers only" do
    csv = EmployeeCsv.Builder.new([])

    assert iodata_to_binary(csv) == "#,Role,First name,Last name\r\n"
  end

  test "a spec should build a csv with columns in order" do
    csv = EmployeeCsv.Builder.new(@employees)

    assert iodata_to_binary(csv) == """
           #,Role,First name,Last name\r\n\
           1,Software Engineer,Emma,Johnson\r\n\
           2,Marketing Manager,Alex,Martinez\r\n\
           """
  end

  test "a spec should build a csv from structs" do
    employees = Enum.map(@employees, &struct(Employee, &1))

    csv = EmployeeCsv.Builder.new(employees)

    assert iodata_to_binary(csv) == """
           #,Role,First name,Last name\r\n\
           1,Software Engineer,Emma,Johnson\r\n\
           2,Marketing Manager,Alex,Martinez\r\n\
           """
  end

  test "a spec can customise a field with a function" do
    csv = EmployeeCsvWithCustomColumn.Builder.new(@employees)

    assert iodata_to_binary(csv) == """
           #,Date of Birth\r\n\
           1,15/05/1990\r\n\
           2,28/11/1985\r\n\
           """
  end

  test "a spec can implement a virtual column" do
    csv = EmployeeCsvWithVirtualColumn.Builder.new(@employees)

    assert iodata_to_binary(csv) == """
           #,Full name\r\n\
           1,Emma Johnson\r\n\
           2,Alex Martinez\r\n\
           """
  end

  test "a spec should raise if a virtual column is not implemented" do
    error_message = """
    Key `full_name` not found. Add a function named \
    `EmployeeCsvWithMissingVirtualColumn.full_name/1` \
    to create a virtual column. Otherwise, ensure that \
    `Csv.Spec` is configured correctly, or the data you \
    provided is accurate: `#{inspect(List.first(@employees))}`
    """

    assert_raise ArgumentError, error_message, fn ->
      EmployeeCsvWithMissingVirtualColumn.Builder.new(@employees)
    end
  end
end
