defmodule Processor do
         
    def listen(no_of_nodes_completed, num_of_nodes, start_time) do
        receive do
            {:response, response} -> 
                no_of_nodes_completed = no_of_nodes_completed + 1
        end


        if no_of_nodes_completed >= num_of_nodes do
            total_time_taken = (:os.system_time(:millisecond) - start_time)
            IO.puts "Total time taken in ms : #{total_time_taken}"
            no_of_nodes_completed
        else
            listen(no_of_nodes_completed, num_of_nodes, start_time)
        end
    end

    def get_pid_list_for_gossip(num_of_nodes, pid_list_for_gossip, main_listener_pid) do
        if num_of_nodes == 0 do
            pid_list_for_gossip
        else
            pid_list_for_gossip = 
                pid_list_for_gossip ++ [spawn(Gossip_Simulator, :listen, [main_listener_pid, 0, nil])]
            get_pid_list_for_gossip(num_of_nodes - 1, pid_list_for_gossip, main_listener_pid)
        end
    end

    def get_pid_list_for_push_sum(num_of_nodes, pid_list_for_gossip, main_listener_pid, i) do
        if num_of_nodes == 0 do
            pid_list_for_gossip
        else
            pid_list_for_gossip = 
                pid_list_for_gossip ++ 
                [spawn(Push_Sum_Simulator, :listen, [main_listener_pid, i, 1, nil, [], false])]
                get_pid_list_for_push_sum(num_of_nodes - 1, pid_list_for_gossip, main_listener_pid, i + 1)
        end
    end

    def start_gossip(pid_neighbors_list_map) do
        Enum.each pid_neighbors_list_map,  fn {k, v} ->
            send k, { :main_response, v }
        end
    end

    def start_push_sum(pid_neighbors_list_map) do
        
        Enum.each pid_neighbors_list_map,  fn {k, v} ->
            send k, { :main_response, v }
        end

        keys = Map.keys(pid_neighbors_list_map)
        key = Enum.at(keys, 0)
        send key, { :main_push_sum_kickstart, "dummy_string" }
    end

    def get_neighbors_for_full_topology(map, list, count) do
        if count == length list do
            map
        else
            map = Map.put(map, Enum.at(list, count), (List.delete_at(list, count)))
            get_neighbors_for_full_topology(map, list, count + 1)
        end
    end

    def get_neighbors_for_line_topology(map, list, count) do
        if count == length list do
            map
        else
            if count == 0 do
                map = Map.put(map, Enum.at(list, count), [] ++ [Enum.at(list, count + 1)])
                get_neighbors_for_line_topology(map, list, count + 1)    

            else 
                if count == ((length list) - 1) do
                    map = Map.put(map, Enum.at(list, count), [] ++ [Enum.at(list, count - 1)])
                    get_neighbors_for_line_topology(map, list, count + 1)    
                else
                    map = Map.put(map, Enum.at(list, count), [] ++ [Enum.at(list, count + 1)] ++ [Enum.at(list, count - 1)])
                    get_neighbors_for_line_topology(map, list, count + 1)
                end
        
            end
        end
    end

    def create_topology(topology, pid_list) do
        pid_neighbors_list_map = Map.new

        case topology do
            "full" ->
                pid_neighbors_list_map = 
                    get_neighbors_for_full_topology(pid_neighbors_list_map, pid_list, 0)
            "line" ->
                pid_neighbors_list_map = 
                    get_neighbors_for_line_topology(pid_neighbors_list_map, pid_list, 0)
        end
    end

    def main(args) do
        {_, options, _} = OptionParser.parse(args)

        if Enum.count(options) == 3 do

            num_of_nodes = String.to_integer(Enum.at(options, 0))
            topology = Enum.at(options, 1)
            algorithm = Enum.at(options, 2)

            case algorithm do
                "gossip" ->
                    pid_list_for_gossip = get_pid_list_for_gossip(num_of_nodes, [], self())
                    pid_neighbors_list_map = create_topology(topology, pid_list_for_gossip)

                    for {k,v} <- pid_neighbors_list_map do
                        IO.puts(inspect(k) <> " -> " <> inspect(v))
                    end

                    start_gossip(pid_neighbors_list_map)
                "push-sum" ->
                    pid_list_for_push_sum = get_pid_list_for_push_sum(num_of_nodes, [], self(), 1)
                    pid_neighbors_list_map = create_topology(topology, pid_list_for_push_sum)

                    for {k,v} <- pid_list_for_push_sum do
                        IO.puts(inspect(k) <> " -> " <> inspect(v))
                    end

                    start_push_sum(pid_neighbors_list_map)
            end

            listen(0, num_of_nodes, :os.system_time(:millisecond))
        end
    end

end