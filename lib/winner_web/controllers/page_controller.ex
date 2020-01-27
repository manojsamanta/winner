defmodule WinnerWeb.PageController do
  use WinnerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def raffle(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      WinnerWeb.WinnerResourcesLive,
      session: %{cookies: conn.cookies}
    )
  end

  def members(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      WinnerWeb.WinnerMembersLive,
      session: %{cookies: conn.cookies}
    )
  end

end
