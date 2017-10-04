defmodule Gossip_Simulator do
    
    def listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list) do
        receive do
            {:main_response, response} -> 
                neighbors_pid_list = response
                no_of_times_message_received = no_of_times_message_received + 1
                #IO.puts response
            {:response, response} -> 
                no_of_times_message_received = no_of_times_message_received + 1
                #IO.puts response
        end

        if no_of_times_message_received == 2 do
            IO.puts "done " <> inspect(self())
            send main_listener_pid, { :response, "done" } 
        end
        gossip(neighbors_pid_list, no_of_times_message_received)
        listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list)
    end

    def gossip(neighbors_pid_list, no_of_times_message_received) do
        if neighbors_pid_list != nil && no_of_times_message_received < 2 do
            random_pid = :rand.uniform(length neighbors_pid_list) - 1
            pid_to_gossip = Enum.at(neighbors_pid_list, random_pid)
            IO.puts(inspect(self()) <> "------>" <> inspect(pid_to_gossip))
            send pid_to_gossip, { :response, ""}
        end
    end

end