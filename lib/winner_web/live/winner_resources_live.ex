defmodule WinnerWeb.WinnerResourcesLive do
  use Phoenix.LiveView

  alias WinnerWeb.RaffleState

  def render(assigns) do
    WinnerWeb.WinnerView.render("index.html", assigns)
  end

  def mount(session, socket) do
    socket =
      socket
      |> new_raffle()

    if connected?(socket) do
      {:ok, schedule_tick(socket)}
    else
      {:ok, socket}
    end
  end

  defp new_raffle(socket) do
      %{resources: resources}=RaffleState.list_resources()
    assign(socket, resources: resources, is_match: false)
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 1000)
    socket
  end

  #
  # add new resource
  #
  def handle_event("add_offer", path, socket) do

    new_resource=path["offer"]["next"]

    if not Enum.member?(socket.assigns.resources, new_resource) do
      RaffleState.add_resource(new_resource)
    end

    %{resources: resources}=RaffleState.list_resources()
    {:noreply, assign(socket, resources: resources)}
  end

  #
  # sort out resource/member combo
  #
  def handle_info(:tick, socket) do
    %{
       resources: resources, 
       members: members,
       member_resources: member_resources
     } = RaffleState.list_resources()

    matches=Enum.flat_map(member_resources, fn {k,v} -> Enum.map(v, &{&1,k}) end) |> Enum.group_by(fn {k,_} -> k end) |> Map.new(fn {k,vs} -> {k,Enum.map(vs, fn {_, v} -> v end)} end)

	IO.inspect matches
    socket=assign(socket, resources: resources, matches: matches, is_match: true)

    new_socket = schedule_tick(socket)
    {:noreply, new_socket}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

end
