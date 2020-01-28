defmodule WinnerWeb.Router do
  use WinnerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WinnerWeb do
    pipe_through :browser

    get "/raffle", PageController, :raffle
    get "/", PageController, :members
  end

  # Other scopes may use custom stacks.
  # scope "/api", WinnerWeb do
  #   pipe_through :api
  # end
end
