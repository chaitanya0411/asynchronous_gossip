defmodule Gossip_Simulator do
    
    def listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list, is_done, arbitrary_pid) do
        receive do
            {:main_response, response} -> 
                neighbors_pid_list = response        
                
            {:main_gossip_kickstart, response} ->
                no_of_times_message_received = no_of_times_message_received + 1

            {:response, response} -> 
                no_of_times_message_received = no_of_times_message_received + 1

            after 100 ->
                #IO.puts "No msg in mailbox for " <> inspect(self()) <> " after 100ms"
        end

        if no_of_times_message_received >= 5 && !is_done do
            is_done = true
            #IO.puts inspect(self()) <> " completed"
            send main_listener_pid, { :response, "done" }
            listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list, is_done, arbitrary_pid) 
        else
            if no_of_times_message_received > 0 do
                gossip(neighbors_pid_list, no_of_times_message_received)
            end
            listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list, is_done, arbitrary_pid)
        end
    end

    def gossip(neighbors_pid_list, no_of_times_message_received) do
        if neighbors_pid_list != nil && no_of_times_message_received < 5 do
            random_pid = :rand.uniform(length neighbors_pid_list) - 1
            pid_to_gossip = Enum.at(neighbors_pid_list, random_pid)
            send pid_to_gossip, { :response, ""}

            random_pid = :rand.uniform(length neighbors_pid_list) - 1
            pid_to_gossip = Enum.at(neighbors_pid_list, random_pid)
            send pid_to_gossip, { :response, ""}
        end
    end

end