clear;
% 计时
tic;

% 参数设置
alpha_1 = 25;
alpha_2 = 15;
beta_1 = 20;
beta_2 = 25;
theta = 30;
delta = 1e-3;
minimum_radius = 200;
data_file = 'data_set_1.xlsx';

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
S_matrix = [1,0,0,0];
U_matrix = [];
cut_out_point = [data_set(1,2),data_set(1,3),data_set(1,4)];
circle_center_point = [0,0,0];
for i = 2:length(data_set)
    U_matrix = [U_matrix;i,Inf,Inf,Inf];
    cut_out_point = [cut_out_point;Inf,Inf,Inf];
    circle_center_point = [circle_center_point;Inf,Inf,Inf];
end

path_matrix = zeros(length(data_set),1);
is_searched = zeros(length(data_set),1);

previous_delta_v = 0;
previous_delta_h = 0;
current_delta_h = 0;
current_delta_v = 0;

% 对起始点
i = 1;
is_searched(i)=1;
for j = U_matrix(:,1).'
    new_delta=distance_matrix(j,i)*delta;
    id_to_S = find(S_matrix == i);
    current_delta_h = S_matrix(id_to_S,4) + new_delta;
    current_delta_v = S_matrix(id_to_S,3) + new_delta;
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
    if distance_matrix(j,i) + S_matrix(id_to_S,2) < U_matrix(id_to_U,2)
        U_matrix(id_to_U,2) = distance_matrix(j,i) + S_matrix(id_to_S,2);
        U_matrix(id_to_U,3) = current_delta_v;
        U_matrix(id_to_U,4) = current_delta_h;
        path_matrix(j)=i;
        cut_out_point(j,:) = [data_set(1,2:4)];
    end
end
for k = U_matrix(:,1).'
    id_to_U = find(U_matrix == k);
    if U_matrix(id_to_U,2) < Inf
        S_matrix = [S_matrix; U_matrix(id_to_U,:)];
        U_matrix(id_to_U,:) = [];
    end
end
% 对初始点搜索完成

% 对其余点
while U_matrix(end,1) == length(data_set)
    % U_matrix = sortrows(U_matrix,2);

    to_do_list = [];
    for i = S_matrix(:,1).'
        if is_searched(i) == 0
            to_do_list = [to_do_list,i];
        end
    end

    for i = to_do_list
        is_searched(i)=1;
        i_previous_point = cut_out_point(i,:);
        i_point = [data_set(i,2:4)];
        v1 = i_point - i_previous_point;
        e1 = v1 / norm(v1);
        i_out_most_point = i_point + 200 * e1;
        for j = U_matrix(:,1).'            
            j_point = [data_set(j,2:4)];
            judge_vector = j_point - i_out_most_point;
            if dot(e1,judge_vector) < 0
                continue;
            end
            [arc_length,O,i_prime] = mycircle(i_previous_point,i_point,j_point);
            new_distance = arc_length + norm(j_point - i_prime);
            new_delta = new_distance * delta;
            id_to_S = find(S_matrix == i);
            current_delta_h = S_matrix(id_to_S,4) + new_delta;
            current_delta_v = S_matrix(id_to_S,3) + new_delta;
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
            if new_distance + S_matrix(id_to_S,2) < U_matrix(id_to_U,2)
                U_matrix(id_to_U,2) = new_distance + S_matrix(id_to_S,2);
                U_matrix(id_to_U,3) = current_delta_v;
                U_matrix(id_to_U,4) = current_delta_h;
                path_matrix(j) = i;
                cut_out_point(j,:) = i_prime;
                circle_center_point(j,:) = O;
            end
        end
    end
    for k = U_matrix(:,1).'
        id_to_U = find(U_matrix == k);
        if U_matrix(id_to_U,2) < Inf
            S_matrix = [S_matrix; U_matrix(id_to_U,:)];
            U_matrix(id_to_U,:) = [];
        end
    end
end

path_result=[length(data_set)];
previous_point = length(data_set);
cut_out_point_result = [];
circle_center_result = [];
while previous_point ~= 1
    cut_out_point_result = [cut_out_point(previous_point,:);cut_out_point_result];
    circle_center_result = [circle_center_point(previous_point,:);circle_center_result];
    previous_point = path_matrix(previous_point);
    path_result = [previous_point , path_result];
end
cut_out_point_result(1,:) = [];
circle_center_result(1,:) = [];

time_to_complete = toc;
