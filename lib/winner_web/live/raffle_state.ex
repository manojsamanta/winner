defmodule WinnerWeb.RaffleState do

  use GenServer

  def init(_init_arg) do
    {:ok, %{
          resources: [],
          members: [],
          member_resources: %{}
      }
    }
  end

  #
  # Functions to add resources/members
  #
  def handle_call({:add_resource, resource_name}, _from, raffle_state) do

      new_raffle_state=%{
        raffle_state | resources: raffle_state.resources ++[resource_name]
      }

    {:reply, new_raffle_state, new_raffle_state}
  end

  def handle_call({:add_member, member_name}, _from, raffle_state) do

      new_raffle_state=%{
        raffle_state | members: raffle_state.members++[member_name]
      }

    {:reply, new_raffle_state, new_raffle_state}
  end

  def handle_call({:add_member_resources, member_name, resources}, _from, raffle_state) do

      new_raffle_state=put_in(raffle_state, [:member_resources, member_name], resources)

    {:reply, raffle_state, new_raffle_state}
  end

  #
  # Listing functions
  #
  def handle_call(:list_resources, _from, raffle_state) do
    {:reply, raffle_state, raffle_state}
  end


  # Public API
  def start_link(_init \\ nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Adding new resource
  def add_resource(resource_name) do
    GenServer.call(__MODULE__, {:add_resource, resource_name})
  end

  # Adding new member
  def add_member(member_name) do
    GenServer.call(__MODULE__, {:add_member, member_name})
  end

  # Assign member to resource
  def add_member_resources(member_name, resources) do
    GenServer.call(__MODULE__, {:add_member_resources, member_name, resources})
  end

  # Listing functions
  def list_resources() do
    GenServer.call(__MODULE__, :list_resources)
  end

end
