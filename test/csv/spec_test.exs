defmodule Csv.SpecTest do
  @moduledoc false
  use ExUnit.Case

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

  test "a csv that declares no columns should return an empty list" do
    assert ZeroColumnCsv.Builder.new(@employees) == []
  end

  test "a csv that declares no columns and takes an empty list should return an empty list" do
    assert ZeroColumnCsv.Builder.new([]) == []
  end

  test "a csv that takes an empty list should return headers" do
    assert EmployeeCsv.Builder.new([]) == [["#", "Role", "First name", "Last name"]]
  end

  test "a csv should return declared rows in order" do
    rows = [
      ["#", "Role", "First name", "Last name"],
      [1, "Software Engineer", "Emma", "Johnson"],
      [2, "Marketing Manager", "Alex", "Martinez"]
    ]

    assert EmployeeCsv.Builder.new(@employees) == rows
  end

  test "a csv should return declared rows in order from structs" do
    employees = Enum.map(@employees, &struct!(Employee, &1))

    rows = [
      ["#", "Role", "First name", "Last name"],
      [1, "Software Engineer", "Emma", "Johnson"],
      [2, "Marketing Manager", "Alex", "Martinez"]
    ]

    assert EmployeeCsv.Builder.new(employees) == rows
  end

  test "a csv should use custom column" do
    assert EmployeeCsvWithCustomColumn.Builder.new(@employees) == [
             ["#", "Date of Birth"],
             [1, "15/05/1990"],
             [2, "28/11/1985"]
           ]
  end

  test "a csv should use virtual column" do
    assert EmployeeCsvWithVirtualColumn.Builder.new(@employees) == [
             ["#", "Full name"],
             [1, "Emma Johnson"],
             [2, "Alex Martinez"]
           ]
  end

  test "a csv must define a function for a virtual field" do
    error_message = """
    Key `full_name` not found. Add a function to \
    `EmployeeCsvWithMissingVirtualColumn.full_name/1` \
    to create a virtual column. Otherwise, ensure that \
    the configured `Csv.Spec` and provided data are \
    accurate: `#{inspect(List.first(@employees))}`
    """

    assert_raise ArgumentError, error_message, fn ->
      EmployeeCsvWithMissingVirtualColumn.Builder.new(@employees)
    end
  end
end
