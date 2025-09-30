defmodule Maui do
  @moduledoc """
  Maui keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defmacro __using__(_opts) do
    quote do
      import Maui
      import Maui.Input
      import Maui.Button
      import Maui.Dropdown
    end
  end

  defdelegate popover_base(assigns), to: Maui.Popover, as: :base
end
