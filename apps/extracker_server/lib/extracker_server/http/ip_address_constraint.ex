defmodule ExtrackerServer.HTTP.IPAddressConstraint do

  @doc """
  A Cowboy parameter constraint for parsing IP addresses.

  ## Examples

      iex> ExtrackerServer.HTTP.IPAddressConstraint.ip_address(:forward, "127.0.0.1")
      {:ok, {127, 0, 0, 1}}

      iex> ExtrackerServer.HTTP.IPAddressConstraint.ip_address(:forward, "fe80::490a:b2ca:6978:75dc")
      {:ok, {65152, 0, 0, 0, 18698, 45770, 27000, 30172}}

      iex> ExtrackerServer.HTTP.IPAddressConstraint.ip_address(:reverse, {127, 0, 0, 1})
      {:ok, "127.0.0.1"}
  """
  def ip_address(operation, value)

  def ip_address(:forward, value) do
    :inet.parse_address(to_charlist(value))
  end

  def ip_address(:reverse, value) do
    case :inet.ntoa(value) do
      x when is_list(x) -> {:ok, to_string(x)}
      e -> e
    end
  end

  def ip_address(:format_error, {:einval, value}) do
    "The value #{value} is not an IPv4 or IPv6 address"
  end
end
