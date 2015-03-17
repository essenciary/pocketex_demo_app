defmodule WebUi.PocketView do
  use WebUi.Web, :view

  def article_host(uri) do
    uri
    |> URI.parse
    |> Map.get(:host)
  end
end
