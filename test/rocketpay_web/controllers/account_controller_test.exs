defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo",
        email: "jose@email.com",
        age: 28
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic dXN1YXJpbzoxMjM0NTY=")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, execute the deposit", %{conn: conn, account_id: account_id} do
      params = %{
        "value" => "50.00"
      }

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:created)

      assert %{
        "account" => %{"balance" => "50.00", "id" => _id},
        "message" => "Ballance changed successfully"
      } = response
    end

    test "when there are invalid params, retuns an error", %{conn: conn, account_id: account_id} do
      params = %{
        "value" => "invalid_value"
      }

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value"}

      assert response == expected_response
    end
  end

  describe "withdraw/2" do
    setup %{conn: conn} do
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo",
        email: "jose@email.com",
        age: 28
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic dXN1YXJpbzoxMjM0NTY=")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, execute the withdraw", %{conn: conn, account_id: account_id} do
      params = %{
        "value" => "100.00"
      }

      # executa um deposito de 100
      conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:created)

      params = %{
        "value" => "50.00"
      }

      # executa um saque de 50
      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
        |> json_response(:created)

      assert %{
        "account" => %{"balance" => "50.00", "id" => _id},
        "message" => "Ballance changed successfully"
      } = response
    end

    test "when there are invalid params, retuns an error", %{conn: conn, account_id: account_id} do
      params = %{
        "value" => "invalid_value"
      }

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid withdraw value"}

      assert response == expected_response
    end
  end

  describe "transaction/3" do
    setup %{conn: conn} do
      # INICIO > cria o usuario FROM
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo_1",
        email: "jose_1@email.com",
        age: 28
      }

      {:ok, %User{account: %Account{id: account_id_from}}} = Rocketpay.create_user(params)
      # FIM > cria o usuario FROM

      # INICIO > cria o usuario TO
      params = %{
        name: "Jose",
        password: "123456",
        nickname: "jsfelipearaujo_2",
        email: "jose_2@email.com",
        age: 28
      }

      {:ok, %User{account: %Account{id: account_id_to}}} = Rocketpay.create_user(params)
      # FIM > cria o usuario TO

      conn = put_req_header(conn, "authorization", "Basic dXN1YXJpbzoxMjM0NTY=")

      {:ok, conn: conn, account_id_from: account_id_from, account_id_to: account_id_to}
    end

    test "when all params are valid, execute the transaction", %{conn: conn, account_id_from: account_id_from, account_id_to: account_id_to} do
      params = %{
        "value" => "100.00"
      }

      # executa um deposito de 100 na conta FROM
      conn
      |> post(Routes.accounts_path(conn, :deposit, account_id_from, params))
      |> json_response(:created)

      # executa uma transaction de 50
      params = %{
        "from_id" => account_id_from,
        "to_id" => account_id_to,
        "value" => "50.00"
      }

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:created)

      expected_response = %{
        "message" => "Transaction executed successfully",
        "transaction" => %{
          "from_account" => %{
            "balance" => "50.00",
            "id" => account_id_from
          },
          "to_account" => %{
            "balance" => "50.00",
            "id" => account_id_to
          }
        }
      }

      assert expected_response == response
    end
  end
end
