defmodule Push_Sum_Simulator do
    
    def listen(main_listener_pid, s, w, neighbors_pid_list, three_rounds_ratio_list, is_done) do
        receive do
            {:main_response, response} -> 
                neighbors_pid_list = response

            {:main_push_sum_kickstart, response} ->
                s = s / 2
                w = w / 2

                ratio = s / w
                three_rounds_ratio_list = three_rounds_ratio_list ++ [ratio]
                push_sum(s, w, neighbors_pid_list)

            {:response, response} ->
                if !is_done do
                    s = s + Enum.at(response, 0)
                    w = w + Enum.at(response, 1)

                    s = s / 2
                    w = w / 2

                    ratio = s / w

                    #IO.puts(inspect(self()) <> " --- " <> to_string ratio)
                    
                    if three_rounds_ratio_list == nil || (length three_rounds_ratio_list) < 4 do
                        three_rounds_ratio_list = three_rounds_ratio_list ++ [ratio]
                    else
                        three_rounds_ratio_list = three_rounds_ratio_list ++ [ratio]
                        three_rounds_ratio_list = List.delete_at(three_rounds_ratio_list, 0)
                    end

                    push_sum(s, w, neighbors_pid_list)
                end
            after 100 ->
                #IO.puts "No msg in mailbox for " <> inspect(self()) <> " after 100ms"
        end

        if three_rounds_ratio_list != nil && (length three_rounds_ratio_list) ==  4 do
            if !is_done do
                if abs((Enum.at(three_rounds_ratio_list, 1) - Enum.at(three_rounds_ratio_list, 0))) <= 0.0000000001 &&
                    abs((Enum.at(three_rounds_ratio_list, 2) - Enum.at(three_rounds_ratio_list, 1))) <= 0.0000000001 &&
                    abs((Enum.at(three_rounds_ratio_list, 3) - Enum.at(three_rounds_ratio_list, 2))) <= 0.0000000001 do
                    is_done = true
                    send main_listener_pid, { :response, "done" }
                end
            else
                :timer.sleep(100)
                push_sum(s, w, neighbors_pid_list)
            end 
        end

        listen(main_listener_pid, s, w, neighbors_pid_list, three_rounds_ratio_list, is_done)
    end

    def push_sum(s, w, neighbors_pid_list) do
        if neighbors_pid_list != nil do
            random_pid = :rand.uniform(length neighbors_pid_list) - 1
            pid_to_gossip = Enum.at(neighbors_pid_list, random_pid)
            send pid_to_gossip, { :response, [] ++ [s] ++ [w]}
        end
    end

end