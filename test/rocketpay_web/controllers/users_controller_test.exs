defmodule RocketpayWeb.UsersControllerTest do
  use RocketpayWeb.ConnCase, async: true

  describe "create_user/2" do
    test "when all params are valid, create the user", %{conn: conn} do
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo",
        email: "jose@email.com",
        age: 28
      }

      response =
        conn
        |> post(Routes.users_path(conn, :create, params))
        |> json_response(:created)

      assert %{
        "message" => "User created",
        "user" => %{
          "account" => %{
            "balance" => "0.00",
            "id" => _account_id
          },
          "id" => _user_id,
          "name" => "Jose",
          "nickname" => "jsfelipearaujo"
        }
      } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn} do
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo",
        email: "invalid_email.com",
        age: 28
      }

      response =
        conn
        |> post(Routes.users_path(conn, :create, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => %{"email" => ["has invalid format"]}}

      assert expected_response == response
    end
  end
end
