% 用于验证path_result的正确性
previous_delta_v = 0;
previous_delta_h = 0;
current_delta_h = 0;
current_delta_v = 0;
total_distance = 0;
flag_correct = false;

i = 1;
total_distance = distance_matrix(path_result(i),path_result(i+1));
new_delta = distance_matrix(path_result(i),path_result(i+1))*delta;
current_delta_h = previous_delta_h + new_delta;
current_delta_v = previous_delta_v + new_delta;
if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(path_result(i+1)) == 1 && path_result(i+1) ~= length(data_set)
    current_delta_v = 0;
elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(path_result(i+1)) == 0 && path_result(i+1) ~= length(data_set)
    current_delta_h = 0;
elseif path_result(i+1) == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
    current_delta_h = 0;
    current_delta_v = 0;
else
    fprintf('Result verification NOT passed.\n');
end

for i = 2:length(path_result)
    if i == length(path_result)
        flag_correct = true;
        fprintf('Running time: %d.\n', time_to_complete);
        fprintf('Result verification passed.\n');
        fprintf('Total hoping is %d.\n',length(path_result)-2);
        fprintf('Total distance is %.f.\n',total_distance);
        break;
    end
    O_point = circle_center_result(i-1,:);
    i_point = data_set(path_result(i),2:4);
    i_p_point = cut_out_point_result(i-1,:);
    j_point = data_set(path_result(i+1),2:4);
    v1 = O_point - i_point;
    v2 = O_point - i_p_point;
    turn_theta = acos(dot(v1,v2) / norm(v1) / norm(v2));
    arc_length = turn_theta * 200;
    v3 = j_point - i_p_point;
    new_delta = (arc_length + norm(v3))*delta;
    current_delta_h = previous_delta_h + new_delta;
    current_delta_v = previous_delta_v + new_delta;
    total_distance = total_distance + arc_length + norm(v3);
    if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(path_result(i+1)) == 1 && path_result(i+1) ~= length(data_set)
        current_delta_v = 0;
    elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(path_result(i+1)) == 0 && path_result(i+1) ~= length(data_set)
        current_delta_h = 0;
    elseif path_result(i+1) == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
        current_delta_h = 0;
        current_delta_v = 0;
    else
        fprintf('Result verification NOT passed.\n');   
        break;
    end
end