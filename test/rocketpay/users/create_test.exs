defmodule Rocketpay.Users.CreateTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.User
  alias Rocketpay.Users.Create

  describe "call/1" do
    test "when all params ar valid, returns an user" do
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo",
        email: "jose@email.com",
        age: 28
      }

      {:ok, %User{id: user_id}} = Create.call(params)

      user = Repo.get(User, user_id)

      # ^ = pin operator, obtem o valor e fixa o valor
      assert %User{name: "Jose", age: 28, id: ^user_id} = user
    end

    test "when there are invalid params ar valid, returns an error" do
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo",
        email: "jose@email.com",
        age: 15
      }

      {:error, changeset} = Create.call(params)

      expected_response = %{age: ["must be greater than or equal to 18"]}

      assert expected_response == errors_on(changeset)
    end
  end
end
