defmodule ExtrackerWeb.TrackerView do
  use ExtrackerWeb, :view

  def render("announce.bencode", %{response: response}) do
    response
  end

  def render("scrape.bencode", %{files: files}) do
    files
  end
end
