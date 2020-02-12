defmodule WinnerWeb.WinnerView do
  use WinnerWeb, :view

  def number_joined(resource, map) do
   case map[resource] do
    nil -> 0
    _   -> Enum.count(map[resource])
   end
  end
end
