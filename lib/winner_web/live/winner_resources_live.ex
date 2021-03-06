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
    assign(socket, resources: resources, shuffles: %{}, is_match: false)
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

    # contributed by @dhedlund, now replaced with invert_map
    # matches=Enum.flat_map(member_resources, fn {k,v} -> Enum.map(v, &{&1,k}) end) |> Enum.group_by(fn {k,_} -> k end) |> Map.new(fn {k,vs} -> {k,Enum.map(vs, fn {_, v} -> v end)} end)

    matches=invert_map(member_resources)
    socket=assign(socket, resources: resources, matches: matches, is_match: true)

    new_socket = schedule_tick(socket)
    {:noreply, new_socket}
  end

  def handle_event("auction", path, socket) do
    resource=path["resource"]
    shuffles = socket.assigns.shuffles

    case socket.assigns.matches[resource] do
     nil -> {:noreply, socket}
     _   -> curr = socket.assigns.matches[resource] |> Enum.shuffle
            shuffles= Map.put(shuffles, resource, curr)
            {:noreply, assign(socket, shuffles: shuffles)}
    end
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  # Contributed by @dhedlund
  defp invert_map(map) do
    pairs = for {key, values} <- map, value <- values, do: {key, value}
    Enum.group_by(pairs, &elem(&1, 1), &elem(&1, 0))
  end

end
