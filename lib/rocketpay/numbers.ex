defmodule Rocketpay.Numbers do
  def sum_from_file(filename) do
    "#{filename}.csv"
    # É passado implicitamente os argumentos para os métodos sem a necessidade de atribuir o valor à uma variavel
    |> File.read()
    |> handle_file()
  end

  defp handle_file({:ok, result}) do
    # o dado trabalho é sempre o 1º argumento da programação
    result =
      result
      |> String.split(",")
      |> Stream.map(fn number -> String.to_integer(number) end)
      |> Enum.sum()

      {:ok, %{result: result}}
    end

  defp handle_file({:error, _reason}), do: {:error, %{message: "Invalid file"}}
end
