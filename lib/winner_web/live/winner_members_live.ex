defmodule WinnerWeb.WinnerMembersLive do
  use Phoenix.LiveView

  alias WinnerWeb.RaffleState

  def render(assigns) do
    WinnerWeb.WinnerView.render("members.html", assigns)
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

    %{resources: resources, 
      members: members, 
      member_resources: member_resources
    }=RaffleState.list_resources()

    assign(socket, 
      resources: resources, 
      members: members, 
      member_resources: member_resources, 
      curr_member: "", 
      curr_member_resources: [], 
      member_entered: false)
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 1000)
    socket
  end

  def handle_info(:tick, socket) do
    %{
       resources: resources, 
       members: members,
       member_resources: member_resources
     }=RaffleState.list_resources()

    socket=assign(socket, resources: resources, members: members)
    new_socket = schedule_tick(socket)
    {:noreply, new_socket}
  end

  #
  # Add new member
  #
  def handle_event("add_member", path, socket) do
    new_member=path["member"]["next"]
    if not Enum.member?(socket.assigns.members, new_member) do
      RaffleState.add_member(new_member)
    end
    %{resources: resources}=RaffleState.list_resources()
    {:noreply, assign(socket, resources: resources, curr_member: new_member, member_entered: true)}
  end

  #
  # Add resouces for the member
  #
  def handle_event("add_member_resources", path, socket) do
    RaffleState.add_member_resources(socket.assigns.curr_member, Map.keys(path))
    {:noreply, assign(socket, curr_member_resources: Map.keys(path))}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

end
