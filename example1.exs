list1 = Enum.to_list(1..1000)
list2 = Enum.to_list(250..750)

Benchee.run(%{
  "filter" => fn -> Enum.filter(list1, &(&1 in list2)) end,
  "mapset" => fn ->
    mapset1 = MapSet.new(list1)
    mapset2 = MapSet.new(list2)

    MapSet.intersection(mapset1, mapset2)
    |> MapSet.to_list()
  end,
  "pr" => fn -> list1 -- list1 -- list2 end
})
