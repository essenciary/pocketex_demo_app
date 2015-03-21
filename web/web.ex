defmodule WebUi.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use WebUi.Web, :controller
      use WebUi.Web, :view

  Keep the definitions in this module short and clean,
  mostly focused on imports, uses and aliases.
  """

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import URL helpers from the router
      import WebUi.Router.Helpers

      # Import all HTML functions (forms, tags, etc)
      use Phoenix.HTML

      using do
        quote do
          # Import common functionality
          import WebUi.Router.Helpers

          # Use Phoenix.HTML to import all HTML functions (forms, tags, etc)
          use Phoenix.HTML
        end
      end
      
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Import URL helpers from the router
      import WebUi.Router.Helpers
    end
  end

  def model do
    quote do
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
