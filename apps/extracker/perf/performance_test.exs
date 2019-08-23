random_download_state = fn() ->
  Enum.random([:incomplete, :complete])
end

info_hash_stream = StreamData.binary(length: 20)
peer_id_stream = StreamData.binary(length: 20)
download_state_stream = Stream.repeatedly(fn -> random_download_state.() end)
peer_id_stream = StreamData.string(:alphanumeric, length: 20)
port_stream = StreamData.integer(1025..65535)
ip_stream = StreamData.tuple({
  StreamData.integer(0..255),
  StreamData.integer(0..255),
  StreamData.integer(0..255),
  StreamData.integer(0..255)
})

peer_stream = Stream.repeatedly(fn ->
  %{
    info_hash: (Enum.take(info_hash_stream, 1) |> Stream.take(1) |> Enum.to_list()),
    peer_id: Enum.take(peer_id_stream, 1),
    port: Enum.take(port_stream, 1),
    uploaded: Enum.take(StreamData.integer(), 1),
    downloaded: Enum.take(StreamData.integer(), 1),
    left: Enum.take(StreamData.integer(), 1),
    ip: Enum.take(ip_stream, 1)
  }
end)

IO.inspect Stream.take(peer_stream, 1) |> Enum.to_list
