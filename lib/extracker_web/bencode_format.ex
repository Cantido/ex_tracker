defmodule ExtrackerWeb.BencodeFormat do
  def encode_to_iodata!(data) do
    Bento.encode!(data)
  end
end
