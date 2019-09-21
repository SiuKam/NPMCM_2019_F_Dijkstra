function [path_result]=dij(w1)

    alpha_1 = 25;
    alpha_2 = 15;
    beta_1 = 20;
    beta_2 = 25;
    theta = 30;
    delta = 1e-3;
    data_file = 'data_set_1.xlsx';
    w1;
    w2 = 1 - w1;

    % 数据读取
    data_set=xlsread(data_file);
    point_v_flag = data_set(:,5);
    distance_matrix=zeros(length(data_set),length(data_set));
    for i = 1 : length(data_set)
        for j = 1 : length(data_set)
            vertical_distance_matrix(i,j)=abs(data_set(i,4)-data_set(j,4));
            horizontal_distance_matrix(i,j)=sqrt((data_set(i,2)-data_set(j,2))^2+(data_set(i,3)-data_set(j,3))^2);
            distance_matrix(i,j)=sqrt((vertical_distance_matrix(i,j))^2+(horizontal_distance_matrix(i,j))^2);
        end
    end

    % 初始化各类变量
    S_matrix = [1,0,0,0,0];
    U_matrix = [];
    for i = 2:length(data_set)
        U_matrix = [U_matrix;i,Inf,Inf,Inf,Inf];
    end

    path_vector = zeros(length(data_set),1);

    previous_delta_v = 0;
    previous_delta_h = 0;
    current_delta_h = 0;
    current_delta_v = 0;

    % 对原点初运行
    i = 1;
    for j = U_matrix(:,1).'
        new_delta=distance_matrix(j,i)*delta;
        current_delta_h = new_delta;
        current_delta_v = new_delta;
        if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(j) == 1 && j ~= length(data_set)
            current_delta_v = 0;
        elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(j) == 0 && j ~= length(data_set)
            current_delta_h = 0;
        elseif j == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
            current_delta_h = 0;
            current_delta_v = 0;
        else
            continue;
        end
        id_to_U = find(U_matrix(:,1) == j);
        U_matrix(id_to_U,2) = distance_matrix(j,i);
        U_matrix(id_to_U,3) = current_delta_v;
        U_matrix(id_to_U,4) = current_delta_h;
        U_matrix(id_to_U,5) = distance_matrix(j,i);
        path_vector(j)=i;
    end
    % 初运行结束

    % 对其他点运行
    while size(U_matrix) ~= [0 0]
        U_matrix = sortrows(U_matrix,5);
        % to_do_list = [];
        
        % for i = U_matrix(:,1).'
        %     id_to_U = find(U_matrix(:,1) == i);
        %     if U_matrix(id_to_U,5) < Inf
        %         to_do_list = [to_do_list, i];
        %     end
        % end

        % for i = to_do_list
        i = U_matrix(1,1);
        for j = U_matrix(:,1).'
            if j == i
                continue;
            end
            new_delta=distance_matrix(j,i)*delta;
            id_to_U_i = find(U_matrix == i);
            id_to_U_j = find(U_matrix == j);
            current_delta_h = U_matrix(id_to_U_i,4) + new_delta;
            current_delta_v = U_matrix(id_to_U_i,3) + new_delta;
            if (current_delta_h < alpha_2) && (current_delta_v < alpha_1) && point_v_flag(j) == 1 && j ~= length(data_set)
                current_delta_v = 0;
            elseif (current_delta_h < beta_2) && (current_delta_v < beta_1) && point_v_flag(j) == 0 && j ~= length(data_set)
                current_delta_h = 0;
            elseif j == length(data_set) && (current_delta_h < theta) && (current_delta_v < theta)
                current_delta_h = 0;
                current_delta_v = 0;
            else
                continue;
            end
            
            if U_matrix(id_to_U_j,5) == Inf
                U_matrix(id_to_U_j,2) = distance_matrix(j,i) + U_matrix(id_to_U_i,2);
                U_matrix(id_to_U_j,3) = current_delta_v;
                U_matrix(id_to_U_j,4) = current_delta_h;
                U_matrix(id_to_U_j,5) = distance_matrix(j,i);
                path_vector(j)=i;
            elseif U_matrix(id_to_U_j,5) < Inf
                
                % distance_factor = U_matrix(id_to_U_i,2) + distance_matrix(j,i) + U_matrix(id_to_U_j,2);
                % delta_factor = U_matrix(id_to_U_j,3) + U_matrix(id_to_U_j,4) + current_delta_h + current_delta_v;
                % factor_old = w1 * U_matrix(id_to_U_j,2) / distance_factor + w2 * (U_matrix(id_to_U_j,3) + U_matrix(id_to_U_j,4)) / delta_factor;
                % factor_new = w1 * (U_matrix(id_to_U_i,2) + distance_matrix(j,i)) / distance_factor + w2 * (current_delta_h + current_delta_v) / delta_factor;
                factor_new = distance_matrix(j,i) + U_matrix(id_to_U_i,2);
                factor_old = U_matrix(id_to_U_j,2);
                if factor_new < factor_old
                    % disp('aaaaaa\n');
                    U_matrix(id_to_U_j,2) = distance_matrix(j,i) + U_matrix(id_to_U_i,2);
                    U_matrix(id_to_U_j,3) = current_delta_v;
                    U_matrix(id_to_U_j,4) = current_delta_h;
                    U_matrix(id_to_U_j,5) = distance_matrix(j,i);
                    path_vector(j)=i;
                end    
            end
        end
        id_to_U = find(U_matrix(:,1) == i);
        S_matrix = [S_matrix; U_matrix(id_to_U,:)];
        U_matrix(id_to_U,:) = [];
    end

    path_result=[length(data_set)];
    previous_point = path_result(1);
    while previous_point ~= 1
        previous_point = path_vector(previous_point);
        path_result = [previous_point , path_result];
    end

    % 用于验证path_result的正确性
    previous_delta_v = 0;
    previous_delta_h = 0;
    current_delta_h = 0;
    current_delta_v = 0;
    total_distance = 0;
    flag_correct = false;
    for i = 1:length(path_result)
        if i == length(path_result)
            flag_correct = true;
            fprintf('Result verification passed.\n')
            fprintf('Total hoping is %d.\n',length(path_result)-2);
            fprintf('Total distance is %.f.\n',total_distance);
            break;
        end
        new_delta=distance_matrix(path_result(i),path_result(i+1))*delta;
        current_delta_h = previous_delta_h + new_delta;
        current_delta_v = previous_delta_v + new_delta;
        total_distance = total_distance + distance_matrix(path_result(i),path_result(i+1));
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


    j=1;
    for i = path_result
        x_result(j) = data_set(i,2);
        y_result(j) = data_set(i,3);
        z_result(j) = data_set(i,4);
        j = j + 1;
    end

    v_point_x = [];
    v_point_y = [];
    v_point_z = [];
    h_point_x = [];
    h_point_y = [];
    h_point_z = [];
    for i = 1:length(data_set)
        if point_v_flag(i) == 1;
            v_point_x = [v_point_x,data_set(i,2)];
            v_point_y = [v_point_y,data_set(i,3)];
            v_point_z = [v_point_z,data_set(i,4)];
        elseif point_v_flag(i) == 0;
            h_point_x = [h_point_x,data_set(i,2)];
            h_point_y = [h_point_y,data_set(i,3)];
            h_point_z = [h_point_z,data_set(i,4)];
        end
    end

    plot3(x_result,y_result,z_result,'*-r',v_point_x,v_point_y,v_point_z,'g.',h_point_x,h_point_y,h_point_z,'b.')
    hold on
    axis equal
end