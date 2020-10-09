list1 = Enum.to_list(1..1000)
list2 = Enum.to_list(250..750)
mapset1 = MapSet.new(list1)
mapset2 = MapSet.new(list2)

Benchee.run(%{
  "filter" => fn -> Enum.filter(list1, &(&1 in list2)) end,
  "mapset" => fn -> MapSet.intersection(mapset1, mapset2) end,
  "pr" => fn -> list1 -- list1 -- list2 end
})
