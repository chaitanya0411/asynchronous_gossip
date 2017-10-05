defmodule Gossip_Simulator do
    
    def listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list, is_done) do
        receive do
            {:main_response, response} -> 
                neighbors_pid_list = response
                no_of_times_message_received = no_of_times_message_received + 1
            {:response, response} -> 
                no_of_times_message_received = no_of_times_message_received + 1
            after 1000 ->
                #IO.puts "No msg in mailbox for " <> inspect(self()) <> " after 1s"
        end

        #IO.puts "no_of_times_message_received for " <> inspect(self()) <> " " <> to_string no_of_times_message_received 

        if no_of_times_message_received >= 2 && !is_done do
            is_done = true
            IO.puts inspect(self()) <> " completed"
            send main_listener_pid, { :response, "done" }
            listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list, is_done) 
        else
            gossip(neighbors_pid_list, no_of_times_message_received)
            listen(main_listener_pid, no_of_times_message_received, neighbors_pid_list, is_done)
        end
    end

    def gossip(neighbors_pid_list, no_of_times_message_received) do
        if neighbors_pid_list != nil && no_of_times_message_received < 2 do
            random_pid = :rand.uniform(length neighbors_pid_list) - 1
            #IO.puts inspect(self()) <> "      " <> to_string random_pid
            pid_to_gossip = Enum.at(neighbors_pid_list, random_pid)
            #IO.puts("gossiping " <> inspect(self()) <> "------>" <> inspect(pid_to_gossip))
            send pid_to_gossip, { :response, ""}
        else
            #IO.puts inspect(self()) <> "      " <> " completed1"
        end
    end

end